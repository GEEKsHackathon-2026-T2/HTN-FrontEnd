import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../core/auth/session.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../report_complete/report_complete_screen.dart';
import 'data/reports_api.dart';
import 'services/exif_location.dart';
import 'widgets/ai_banner.dart';
import 'widgets/description_section.dart';
import 'widgets/location_section.dart';
import 'widgets/photo_upload_section.dart';
import 'widgets/report_type_section.dart';
import 'widgets/submit_bar.dart';

const _maxMediaFiles = 10;

enum _LocationSource { none, exif, manual }

class AiComplaintScreen extends StatefulWidget {
  const AiComplaintScreen({super.key});

  @override
  State<AiComplaintScreen> createState() => _AiComplaintScreenState();
}

class _AiComplaintScreenState extends State<AiComplaintScreen> {
  final _picker = ImagePicker();
  final _api = ReportsApi();
  final _descriptionController = TextEditingController();

  final List<XFile> _mediaFiles = [];

  List<CategoryGroup>? _categories;
  bool _loadingCategories = true;
  bool _categoriesError = false;
  String? _selectedCategoryCode;

  LatLng? _location;
  _LocationSource _locationSource = _LocationSource.none;
  // Best-effort only, used to center the manual picker — never submitted
  // directly, since the report's location should come from the photo (EXIF)
  // or an explicit manual pick, not "wherever the reporter is standing now".
  Position? _devicePosition;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadDevicePosition();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = false;
    });
    try {
      final groups = await _api.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = groups;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        _categoriesError = true;
      });
    }
  }

  Future<void> _loadDevicePosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final denied = permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever;
      if (denied || !await Geolocator.isLocationServiceEnabled()) return;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() => _devicePosition = position);
    } catch (_) {
      // Best-effort only — the picker just falls back to a default center.
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addMedia(List<XFile> files) {
    if (files.isEmpty) return;
    final remaining = _maxMediaFiles - _mediaFiles.length;
    if (remaining <= 0) {
      _showError('사진은 최대 $_maxMediaFiles장까지 첨부할 수 있습니다.');
      return;
    }
    final toAdd = files.take(remaining).toList();
    setState(() => _mediaFiles.addAll(toAdd));
    if (files.length > toAdd.length) {
      _showError('사진은 최대 $_maxMediaFiles장까지 첨부할 수 있습니다.');
    }
    _tryAutoLocationFromExif(toAdd);
  }

  /// Uses the first newly-added photo that has GPS EXIF data — but only
  /// while no location has been set yet, so it never overrides a manual
  /// pick the user already made.
  Future<void> _tryAutoLocationFromExif(List<XFile> newFiles) async {
    for (final file in newFiles) {
      if (_locationSource != _LocationSource.none) return;
      final point = await extractExifLocation(file.path);
      if (point == null) continue;
      if (!mounted || _locationSource != _LocationSource.none) return;
      setState(() {
        _location = point;
        _locationSource = _LocationSource.exif;
      });
      return;
    }
  }

  Future<void> _openLocationPicker() async {
    final center = _location ??
        (_devicePosition != null
            ? LatLng(_devicePosition!.latitude, _devicePosition!.longitude)
            : null);
    final result = await context.push<LatLng>('/location-picker', extra: center);
    if (result == null || !mounted) return;
    setState(() {
      _location = result;
      _locationSource = _LocationSource.manual;
    });
  }

  Future<void> _pickCamera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (file == null) return;
      _addMedia([file]);
    } catch (e) {
      _showError('카메라를 사용할 수 없습니다: $e');
    }
  }

  Future<void> _pickGallery() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      _addMedia(files);
    } catch (e) {
      _showError('갤러리를 사용할 수 없습니다: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() => _mediaFiles.removeAt(index));
  }

  String? get _locationSourceLabel {
    switch (_locationSource) {
      case _LocationSource.exif:
        return '사진에서 자동으로 인식된 위치';
      case _LocationSource.manual:
        return '직접 선택한 위치';
      case _LocationSource.none:
        return null;
    }
  }

  Future<void> _submit() async {
    final matches = _categories?.where((g) => g.code == _selectedCategoryCode);
    final selectedGroup = matches != null && matches.isNotEmpty ? matches.first : null;
    final leaf = selectedGroup != null && selectedGroup.children.isNotEmpty
        ? selectedGroup.children.first
        : null;

    if (leaf == null) {
      _showError('제보 유형을 선택해주세요.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await Session.ensureSignedIn();

      final reportId = await _api.createReport(
        categoryCode: leaf.code,
        content: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        latitude: _location?.latitude,
        longitude: _location?.longitude,
      );

      if (_mediaFiles.isNotEmpty) {
        final byteEntries = await Future.wait(_mediaFiles.map((f) => f.readAsBytes()));
        final mimeTypes = [
          for (var i = 0; i < _mediaFiles.length; i++) _mediaFiles[i].mimeType ?? 'image/jpeg',
        ];

        final uploads = await _api.presignMedia(
          reportId: reportId,
          files: [
            for (var i = 0; i < _mediaFiles.length; i++)
              PresignFile(
                fileName: _mediaFiles[i].name,
                mimeType: mimeTypes[i],
                sizeBytes: byteEntries[i].length,
              ),
          ],
        );

        for (var i = 0; i < uploads.length; i++) {
          await _api.uploadBytes(uploads[i].uploadUrl, byteEntries[i], mimeTypes[i]);
          await _api.completeMedia(reportId: reportId, mediaId: uploads[i].mediaId);
        }
      }

      final result = await _api.submitReport(reportId);

      if (!mounted) return;
      context.pushReplacement(
        '/report-complete',
        extra: ReportCompletionData(
          result: result,
          categoryNameKo: selectedGroup!.nameKo,
        ),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('제보 접수에 실패했습니다: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          title: const Text(
            '민원 접수',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const AiBanner(),
            const SizedBox(height: 20),
            PhotoUploadSection(
              mediaFiles: _mediaFiles,
              onPickCamera: _pickCamera,
              onPickGallery: _pickGallery,
              onRemove: _removeMedia,
            ),
            const SizedBox(height: 20),
            LocationSection(
              point: _location,
              sourceLabel: _locationSourceLabel,
              onEditLocation: _openLocationPicker,
            ),
            const SizedBox(height: 20),
            ReportTypeSection(
              groups: _categories ?? const [],
              loading: _loadingCategories,
              error: _categoriesError,
              selectedCode: _selectedCategoryCode,
              onSelect: (code) => setState(() => _selectedCategoryCode = code),
              onRetry: _loadCategories,
            ),
            const SizedBox(height: 20),
            DescriptionSection(controller: _descriptionController),
          ],
        ),
        bottomNavigationBar: SubmitBar(onSubmit: _submit, loading: _submitting),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';

class CategoryLeaf {
  const CategoryLeaf({required this.code, required this.nameKo});

  final String code;
  final String nameKo;

  factory CategoryLeaf.fromJson(Map<String, dynamic> json) {
    return CategoryLeaf(
      code: json['code'] as String,
      nameKo: json['nameKo'] as String,
    );
  }
}

class CategoryGroup {
  const CategoryGroup({
    required this.code,
    required this.nameKo,
    required this.children,
  });

  final String code;
  final String nameKo;
  final List<CategoryLeaf> children;

  factory CategoryGroup.fromJson(Map<String, dynamic> json) {
    return CategoryGroup(
      code: json['code'] as String,
      nameKo: json['nameKo'] as String,
      children: (json['children'] as List)
          .map((e) => CategoryLeaf.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MediaUpload {
  const MediaUpload({required this.mediaId, required this.uploadUrl});

  final String mediaId;
  final String uploadUrl;
}

class PresignFile {
  const PresignFile({
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String fileName;
  final String mimeType;
  final int sizeBytes;
}

DateTime? _parseDate(dynamic value) {
  return value is String ? DateTime.tryParse(value) : null;
}

/// The backend doesn't return a formatted receipt number or an assigned
/// department name yet (checked `reports.controller.ts` submit response and
/// `report.serializer.ts` — neither field exists there today). These are
/// read defensively so the UI upgrades automatically once the backend adds
/// them, without another frontend change.
class SubmitResult {
  const SubmitResult({
    required this.id,
    required this.status,
    this.currentDueAt,
    this.receiptNumber,
    this.departmentName,
  });

  final String id;
  final String status;
  final DateTime? currentDueAt;
  final String? receiptNumber;
  final String? departmentName;

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    final deadline = json['deadline'] as Map<String, dynamic>?;
    return SubmitResult(
      id: json['id'] as String,
      status: json['status'] as String,
      currentDueAt: _parseDate(deadline?['currentDueAt']),
      receiptNumber: json['receiptNumber'] as String?,
      departmentName: json['departmentName'] as String?,
    );
  }
}

class MyReport {
  const MyReport({
    required this.id,
    required this.status,
    this.categoryNameKo,
    this.submittedAt,
    this.currentDueAt,
    this.receiptNumber,
    this.departmentName,
  });

  final String id;
  final String status;
  final String? categoryNameKo;
  final DateTime? submittedAt;
  final DateTime? currentDueAt;
  final String? receiptNumber;
  final String? departmentName;

  factory MyReport.fromJson(Map<String, dynamic> json) {
    final deadline = json['deadline'] as Map<String, dynamic>?;
    return MyReport(
      id: json['id'] as String,
      status: json['status'] as String,
      categoryNameKo: json['categoryNameKo'] as String?,
      submittedAt: _parseDate(json['submittedAt']),
      currentDueAt: _parseDate(deadline?['currentDueAt']),
      receiptNumber: json['receiptNumber'] as String?,
      departmentName: json['departmentName'] as String?,
    );
  }
}

/// Wraps the `/categories`, `/reports`, and `/me/reports` endpoints
/// (docs/05-api.md §3, §4).
class ReportsApi {
  ReportsApi({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<List<CategoryGroup>> fetchCategories() async {
    final data = await _client.get('/categories') as List;
    return data
        .map((e) => CategoryGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates a DRAFT report and returns its id.
  Future<String> createReport({
    required String categoryCode,
    String? content,
    double? latitude,
    double? longitude,
  }) async {
    final res = await _client.post('/reports', {
      'categoryCode': categoryCode,
      'content': ?content,
      'latitude': ?latitude,
      'longitude': ?longitude,
    });
    return res['id'] as String;
  }

  /// Presigns upload URLs for one or more files in a single call — the
  /// backend returns one upload slot per file, in the same order.
  Future<List<MediaUpload>> presignMedia({
    required String reportId,
    required List<PresignFile> files,
  }) async {
    final res = await _client.post('/reports/$reportId/media/presign', {
      'files': files
          .map((f) => {
                'fileName': f.fileName,
                'mimeType': f.mimeType,
                'sizeBytes': f.sizeBytes,
              })
          .toList(),
    });
    final uploads = res['uploads'] as List;
    return uploads
        .map(
          (u) => MediaUpload(
            mediaId: (u as Map<String, dynamic>)['mediaId'] as String,
            uploadUrl: u['uploadUrl'] as String,
          ),
        )
        .toList();
  }

  /// Uploads bytes straight to storage — file bytes never pass through the
  /// API server (docs/05-api.md §2.3).
  Future<void> uploadBytes(String uploadUrl, Uint8List bytes, String mimeType) async {
    final res = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': mimeType},
      body: bytes,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('UPLOAD_FAILED', '파일 업로드에 실패했습니다.');
    }
  }

  Future<void> completeMedia({required String reportId, required String mediaId}) {
    return _client.post('/reports/$reportId/media/$mediaId/complete', const {});
  }

  Future<SubmitResult> submitReport(String reportId) async {
    final res = await _client.post('/reports/$reportId/submit', const {});
    return SubmitResult.fromJson(res);
  }

  /// 내 제보 목록 — newest first, to match "지금까지 올린 것" stacking.
  Future<List<MyReport>> fetchMyReports() async {
    final res = await _client.get('/me/reports?sort=recent') as Map<String, dynamic>;
    final data = res['data'] as List;
    return data.map((e) => MyReport.fromJson(e as Map<String, dynamic>)).toList();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import 'form_section_card.dart';

class PhotoUploadSection extends StatelessWidget {
  const PhotoUploadSection({
    super.key,
    required this.mediaFiles,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemove,
  });

  final List<XFile> mediaFiles;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: '사진 또는 영상 업로드',
      subtitle: '시설물 상태와 위험 부위가 잘 보이도록 촬영해 주세요.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _UploadButton(
                  icon: Icons.camera_alt_outlined,
                  label: '카메라',
                  onTap: onPickCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UploadButton(
                  icon: Icons.image_outlined,
                  label: '갤러리',
                  onTap: onPickGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          mediaFiles.isEmpty
              ? Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textSecondary,
                      size: 32,
                    ),
                  ),
                )
              : _MediaCarousel(mediaFiles: mediaFiles, onRemove: onRemove),
        ],
      ),
    );
  }
}

class _MediaCarousel extends StatefulWidget {
  const _MediaCarousel({required this.mediaFiles, required this.onRemove});

  final List<XFile> mediaFiles;
  final ValueChanged<int> onRemove;

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void didUpdateWidget(covariant _MediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= widget.mediaFiles.length) {
      _page = widget.mediaFiles.isEmpty ? 0 : widget.mediaFiles.length - 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.mediaFiles.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  return Image.file(
                    File(widget.mediaFiles[index].path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _RemoveButton(onTap: () => widget.onRemove(_page)),
          ),
          if (widget.mediaFiles.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.mediaFiles.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

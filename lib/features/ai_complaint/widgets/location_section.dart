import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import 'form_section_card.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({
    super.key,
    required this.point,
    required this.sourceLabel,
    required this.onEditLocation,
  });

  /// null until an EXIF hit or a manual pick has produced coordinates.
  final LatLng? point;

  /// How [point] was obtained ("사진에서 자동으로 인식된 위치" / "직접 선택한 위치"),
  /// or null when [point] is null.
  final String? sourceLabel;

  final VoidCallback onEditLocation;

  @override
  Widget build(BuildContext context) {
    final current = point;
    return FormSectionCard(
      title: '위치 정보',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  current == null
                      ? '위치가 아직 선택되지 않았습니다.'
                      : '$sourceLabel · 위도 ${current.latitude.toStringAsFixed(5)}, '
                          '경도 ${current.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onEditLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 140,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECE3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: current == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined, color: AppColors.primary, size: 28),
                          SizedBox(height: 6),
                          Text(
                            '지도에서 위치 선택하기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : IgnorePointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: current,
                          initialZoom: 16,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.htnFrontend',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: current,
                                width: 40,
                                height: 40,
                                alignment: Alignment.topCenter,
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onEditLocation,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '위치 수정',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickServiceSection extends StatelessWidget {
  const QuickServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _QuickServiceCard(
            icon: Icons.auto_awesome,
            label: 'AI 민원신청',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _QuickServiceCard(
            icon: Icons.description_outlined,
            label: '적극행정 신청',
          ),
        ),
      ],
    );
  }
}

class _QuickServiceCard extends StatelessWidget {
  const _QuickServiceCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

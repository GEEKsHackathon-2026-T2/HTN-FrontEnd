import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          const Text(
            '우선해줘',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

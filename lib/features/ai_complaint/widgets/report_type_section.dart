import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/reports_api.dart';
import 'form_section_card.dart';

class ReportTypeSection extends StatelessWidget {
  const ReportTypeSection({
    super.key,
    required this.groups,
    required this.loading,
    required this.error,
    required this.selectedCode,
    required this.onSelect,
    required this.onRetry,
  });

  final List<CategoryGroup> groups;
  final bool loading;
  final bool error;
  final String? selectedCode;
  final ValueChanged<String> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: '제보 유형',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    if (error || groups.isEmpty) {
      return Column(
        children: [
          const Text(
            '제보 유형을 불러오지 못했습니다. 네트워크 연결을 확인해주세요.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('다시 시도', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final group in groups)
          _TypeChip(
            label: group.nameKo,
            active: group.code == selectedCode,
            onTap: () => onSelect(group.code),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

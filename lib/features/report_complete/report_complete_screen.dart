import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/labeled_row.dart';
import '../ai_complaint/data/reports_api.dart';

class ReportCompletionData {
  const ReportCompletionData({required this.result, required this.categoryNameKo});

  final SubmitResult result;
  final String categoryNameKo;
}

class ReportCompleteScreen extends StatelessWidget {
  const ReportCompleteScreen({super.key, required this.data});

  final ReportCompletionData data;

  @override
  Widget build(BuildContext context) {
    // The backend doesn't return a formatted receipt number or the assigned
    // department yet, so these fall back to the raw report id / a pending
    // label until the backend adds `receiptNumber` / `departmentName`.
    final receiptNumber = data.result.receiptNumber ?? data.result.id;
    final departmentName = data.result.departmentName ?? '배정 확인 중';

    return Scaffold(
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
          '제보 완료',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '제보 접수 완료',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'AI 실시간 정밀 분석 결과 및 제보 내용이 관할 지자체 담당 부서로 즉시 전달되었습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          LabeledRow(label: '접수 번호', value: receiptNumber),
                          const Divider(height: 1, color: AppColors.divider),
                          LabeledRow(label: '관할 부서', value: departmentName),
                          const Divider(height: 1, color: AppColors.divider),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '예상 담당자 지정 및 검토 시간',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push('/report-status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    '접수 현황 보기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  '홈으로 이동',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

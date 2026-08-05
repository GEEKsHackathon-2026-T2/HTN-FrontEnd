import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/labeled_row.dart';
import '../ai_complaint/data/reports_api.dart';

class ReportStatusScreen extends StatefulWidget {
  const ReportStatusScreen({super.key});

  @override
  State<ReportStatusScreen> createState() => _ReportStatusScreenState();
}

class _ReportStatusScreenState extends State<ReportStatusScreen> {
  final _api = ReportsApi();

  List<MyReport>? _reports;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final reports = await _api.fetchMyReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '접수 현황',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '접수 현황을 불러오지 못했습니다.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _load,
              child: const Text(
                '다시 시도',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
    final reports = _reports ?? const [];
    if (reports.isEmpty) {
      return const Center(
        child: Text(
          '아직 접수한 민원이 없습니다.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _ReportCard(report: reports[index]),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final MyReport report;

  @override
  Widget build(BuildContext context) {
    final receiptNumber = report.receiptNumber ?? report.id;
    final departmentName =
        report.departmentName ?? report.categoryNameKo ?? '배정 확인 중';

    return Container(
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
    );
  }
}

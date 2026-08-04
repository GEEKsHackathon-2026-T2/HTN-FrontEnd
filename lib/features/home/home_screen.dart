import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/category_section.dart';
import 'widgets/detail_service_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/promo_banner.dart';
import 'widgets/quick_service_section.dart';
import 'widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: const [
                    PromoBanner(),
                    SizedBox(height: 28),
                    SectionTitle('빠른 서비스'),
                    SizedBox(height: 14),
                    QuickServiceSection(),
                    SizedBox(height: 20),
                    HomeSearchBar(),
                    SizedBox(height: 28),
                    SectionTitle('자주묻는 질문'),
                    SizedBox(height: 14),
                    FaqSection(),
                    SizedBox(height: 28),
                    SectionTitle('상세 서비스'),
                    SizedBox(height: 14),
                    DetailServiceSection(),
                    SizedBox(height: 28),
                    SectionTitle('카테고리'),
                    SizedBox(height: 14),
                    CategorySection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

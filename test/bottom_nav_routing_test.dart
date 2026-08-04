import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:htn_frontend/core/routes/app_router.dart';

void main() {
  testWidgets('bottom nav navigates between home, complaint, status, my', (
    tester,
  ) async {
    router.go('/home');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('정부AI민원'), findsOneWidget);

    await tester.tap(find.text('민원'));
    await tester.pumpAndSettle();
    expect(find.text('민원 페이지'), findsOneWidget);

    await tester.tap(find.text('현황'));
    await tester.pumpAndSettle();
    expect(find.text('현황 페이지'), findsOneWidget);

    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.text('마이 페이지'), findsOneWidget);

    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    expect(find.text('정부AI민원'), findsOneWidget);
  });
}

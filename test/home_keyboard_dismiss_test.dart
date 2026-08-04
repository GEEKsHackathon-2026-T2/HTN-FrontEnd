import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:htn_frontend/features/home/home_screen.dart';

void main() {
  testWidgets('tapping outside the search field dismisses the keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('빠른 서비스'));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
  });
}

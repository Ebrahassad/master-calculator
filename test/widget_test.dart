import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:master_calculator/main.dart';

void main() {
  testWidgets('App launches and shows the landing screen menu buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MasterCalculatorApp());
    await tester.pumpAndSettle();

    // أيقونات أزرار التنقل الخمسة في الشاشة الرئيسية
    expect(find.byIcon(Icons.functions), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
    expect(find.byIcon(Icons.attach_money_rounded), findsOneWidget);
  });
}

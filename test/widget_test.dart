import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:master_calculator/main.dart';

void main() {
  testWidgets('App launches and shows the bottom navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(const MasterCalculatorApp());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.functions), findsOneWidget);
  });
}

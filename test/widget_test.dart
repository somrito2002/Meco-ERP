import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meco/main.dart';

void main() {
  testWidgets('Login screen renders core elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MecoApp());
    await tester.pumpAndSettle();

    expect(find.text('Meco'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Send your LoginID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('support@meco.io'), findsOneWidget);
  });

  testWidgets('Theme toggle switches between light and dark themes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MecoApp());
    await tester.pumpAndSettle();

    Brightness brightnessOf() =>
        Theme.of(tester.element(find.text('Meco'))).brightness;

    expect(brightnessOf(), Brightness.light);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();
    expect(brightnessOf(), Brightness.dark);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();
    expect(brightnessOf(), Brightness.light);
  });
}
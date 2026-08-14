import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meco/main.dart';

/// Lets real async work (asset load + image decode + particle sampling)
/// finish before the fake-clock pumps drive the splash animation to
/// completion. Polls until the particle reveal is on screen.
Future<void> pumpThroughSplash(WidgetTester tester) async {
  await tester.pumpWidget(const MecoApp());
  await tester.runAsync(() async {
    for (int i = 0;
        i < 60 && !tester.any(find.byType(CustomPaint));
        i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
  });
  await tester.pump(); // build with the decoded image, start animation
  await tester.pumpAndSettle(); // run the particle reveal to completion
  await tester.pump(const Duration(milliseconds: 350)); // fire nav delay
  await tester.pumpAndSettle(); // complete the route transition
}

void main() {
  testWidgets('Login screen renders core elements', (WidgetTester tester) async {
    await pumpThroughSplash(tester);

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
    await pumpThroughSplash(tester);

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
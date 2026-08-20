import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meco/main.dart';
import 'package:meco/theme.dart';

/// Drives the splash through its real-time timers and animations:
/// particle reveal (2100ms), pre-shine delay (200ms), shine sweep
/// (1400ms), post-shine delay (600ms), session check, then navigation.
Future<void> pumpThroughSplash(WidgetTester tester) async {
  await tester.pumpWidget(const MecoApp());
  await tester.runAsync(() async {
    for (int i = 0;
        i < 60 && !tester.any(find.byType(CustomPaint));
        i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
    // Advance the fake clock in steps so the splash's timers fire and its
    // animations tick: reveal 2100ms + 200ms + shine 1400ms + 600ms + nav.
    for (int i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400)); // route transition
  await tester.pump();
}

/// Splash -> onboarding -> login by tapping "Get started".
Future<void> pumpToLogin(WidgetTester tester) async {
  await pumpThroughSplash(tester);
  await tester.tap(find.text('Get started →'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  testWidgets('Login screen renders core elements', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpToLogin(tester);

    expect(find.text('MECO'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Send your LoginID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('support@meco.io'), findsOneWidget);
  });

  testWidgets('Login screen follows system theme with no theme toggle', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await pumpToLogin(tester);

    Brightness brightnessOf() =>
        Theme.of(tester.element(find.text('MECO'))).brightness;

    expect(brightnessOf(), Brightness.light);
    expect(find.byIcon(Icons.dark_mode_outlined), findsNothing);
    expect(find.byIcon(Icons.light_mode_outlined), findsNothing);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(brightnessOf(), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(brightnessOf(), Brightness.light);
  });

  testWidgets('Signed-in user skips onboarding and goes straight to dashboard', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'logged_in': true,
      // Login ID initial ('B') deliberately differs from the name initial
      // ('A') to prove the avatar is derived from the Login ID.
      'login_id': 'billing@meco.com',
      'department': 'Billing & Commercial',
      'name': 'Accounts User',
      'user_id': '10003',
    });
    await pumpThroughSplash(tester);

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
    expect(find.text('Get started →'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('Profile popup shows the login-ID initial and user info', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'logged_in': true,
      'login_id': 'hr@meco.com',
      'department': 'Human Resources (HR)',
      'name': 'HR User',
      'user_id': '10007',
    });
    await pumpThroughSplash(tester);

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pump();

    expect(find.text('Logged-in as'), findsOneWidget);
    expect(find.text('HR User'), findsOneWidget);
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('Human Resources (HR)'), findsOneWidget);
    expect(find.text('User ID'), findsOneWidget);
    expect(find.text('10007'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    // 'H' appears in both the app-bar avatar and the popup avatar.
    expect(find.text('H'), findsNWidgets(2));
    // Both avatars share the same Meco green background.
    final Iterable<CircleAvatar> avatars = tester
        .widgetList<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatars, hasLength(2));
    expect(
      avatars.every(
        (avatar) => avatar.backgroundColor == AppPalette.profileAvatar,
      ),
      isTrue,
    );
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Notifications popup shows only the user department feed', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'logged_in': true,
      'login_id': 'accounts@meco.com',
      'department': 'Accounts & Finance',
      'name': 'Accounts User',
      'user_id': '10001',
    });
    await pumpThroughSplash(tester);

    final Size screen = tester.getSize(find.byType(MaterialApp));
    expect(screen.width, greaterThan(300)); // sanity: width >= popup max

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pump();

    // Department-specific badge count on the bell.
    expect(find.text('3'), findsOneWidget);
    // Only Accounts & Finance notifications.
    expect(find.text('Money received'), findsOneWidget);
    expect(find.text('Payment approved'), findsOneWidget);
    expect(find.text('Invoice processed'), findsOneWidget);
    // Other departments' notifications must NOT leak through.
    expect(find.text('Site Visit completed'), findsNothing);
    expect(find.text('Purchase order approved'), findsNothing);
    expect(find.text('Electrical inspection completed'), findsNothing);
    expect(find.text('3 new'), findsOneWidget);
    expect(find.text('Mark read'), findsOneWidget);

    final Finder panel = find.ancestor(
      of: find.text('Money received'),
      matching: find.byType(Material),
    );
    final Rect rect = tester.getRect(panel.first);

    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(screen.width));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(screen.height));
    expect(rect.width, lessThanOrEqualTo(screen.width - 24));
  });

  testWidgets('Civil user sees only Civil notifications', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'logged_in': true,
      'login_id': 'civil@meco.com',
      'department': 'Civil / Construction',
      'name': 'Civil User',
      'user_id': '10004',
    });
    await pumpThroughSplash(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('Site Visit completed'), findsOneWidget);
    expect(find.text('Construction progress updated'), findsOneWidget);
    expect(find.text('Material consumed'), findsOneWidget);
    expect(find.text('Money received'), findsNothing);
    expect(find.text('3 new'), findsOneWidget);
  });

  testWidgets('HR sees notifications from every department', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'logged_in': true,
      'login_id': 'hr@meco.com',
      'department': 'Human Resources (HR)',
      'name': 'HR User',
      'user_id': '10007',
    });
    await pumpThroughSplash(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pump();

    expect(find.text('45'), findsOneWidget);
    expect(find.text('45 new'), findsOneWidget);

    final Finder panel = find.ancestor(
      of: find.text('45 new'),
      matching: find.byType(Material),
    );
    final Finder popupList = find.descendant(
      of: panel.first,
      matching: find.byType(Scrollable),
    );

    // The popup list lazily builds items, so scroll until each
    // cross-department notification becomes visible.
    Future<void> expectVisible(String title) async {
      await tester.scrollUntilVisible(
        find.text(title),
        60,
        scrollable: popupList.first,
      );
      expect(find.text(title), findsOneWidget);
    }

    await expectVisible('Money received'); // Accounts & Finance
    await expectVisible('Site Visit completed'); // Civil / Construction
    await expectVisible('Purchase order approved'); // Purchase & Procurement
    await expectVisible('Electrical inspection completed'); // Electrical
    await expectVisible('Mechanical inspection completed'); // Mechanical
    await expectVisible('Project progress updated'); // Projects & Operations
    await expectVisible('Production target completed'); // Plant / Production
    await expectVisible('Drawing approved'); // Design & Technical
    await expectVisible('Tender submitted'); // Tender Cell & Coordination
    await expectVisible('Administrative request completed'); // Administration
    await expectVisible('Management report generated'); // Management
    await expectVisible('Invoice generated'); // Billing & Commercial
    await expectVisible('Maintenance request completed'); // Maintenance
    await expectVisible('Inspection completed'); // Vigilance
  });

  testWidgets('Notifications popup fits on a small phone', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'logged_in': true,
      'login_id': 'accounts@meco.com',
      'department': 'Accounts & Finance',
      'name': 'Accounts User',
      'user_id': '10001',
    });
    await pumpThroughSplash(tester);

    // Resize to a small phone only after landing on the dashboard so the
    // test checks the popup itself, not other screens.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pump();

    const Size screen = Size(320, 640);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pump();

    expect(find.text('Money received'), findsOneWidget);
    expect(find.text('Payment approved'), findsOneWidget);
    expect(find.text('Invoice processed'), findsOneWidget);
    expect(find.text('Site Visit completed'), findsNothing);

    final Finder panel = find.ancestor(
      of: find.text('Money received'),
      matching: find.byType(Material),
    );
    final Rect rect = tester.getRect(panel.first);

    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(screen.width));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(screen.height));
    expect(rect.width, lessThanOrEqualTo(screen.width - 24));
  });
}
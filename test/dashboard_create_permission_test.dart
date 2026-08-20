import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meco/auth/demo_users.dart';
import 'package:meco/auth/permissions.dart';
import 'package:meco/main.dart';
import 'package:meco/models/demo_user.dart';

// ── Helper: pump through splash straight to the signed-in dashboard ──────────

Future<void> pumpThroughSplash(WidgetTester tester) async {
  await tester.pumpWidget(const MecoApp());
  await tester.runAsync(() async {
    for (int i = 0;
        i < 60 && !tester.any(find.byType(CustomPaint));
        i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
    for (int i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

// ── Permission helper unit tests ─────────────────────────────────────────────

void main() {
  group('userHasPermission - createDashboard', () {
    DemoUser userFor(String department) => DemoUser(
          loginId: 'x@meco.com',
          password: '1234',
          department: department,
          name: 'Test',
          userId: '00001',
        );

    test('HR department has createDashboard permission', () {
      expect(
        userHasPermission(
          userFor('Human Resources (HR)'),
          AppPermission.createDashboard,
        ),
        isTrue,
      );
    });

    test('HR shorthand alias has createDashboard permission', () {
      expect(
        userHasPermission(userFor('HR'), AppPermission.createDashboard),
        isTrue,
      );
    });

    test('HR check is case-insensitive and trims whitespace', () {
      expect(
        userHasPermission(
          userFor('  human resources (hr)  '),
          AppPermission.createDashboard,
        ),
        isTrue,
      );
    });

    test('every non-HR department lacks createDashboard permission', () {
      const nonHrDepartments = [
        'Accounts & Finance',
        'Purchase & Procurement',
        'Civil / Construction',
        'Electrical',
        'Mechanical',
        'Projects & Operations',
        'Plant / Production',
        'Design & Technical',
        'Tender Cell & Coordination',
        'Administration / Back Office',
        'Management / Executive',
        'Billing & Commercial',
        'Maintenance',
        'Vigilance',
        'IT/Developer',
        'IT/Consultant',
      ];
      for (final department in nonHrDepartments) {
        expect(
          userHasPermission(userFor(department), AppPermission.createDashboard),
          isFalse,
          reason: '$department must NOT have createDashboard permission',
        );
      }
    });

    test('departments containing similar text are not granted', () {
      expect(
        userHasPermission(userFor('Hr Admin'), AppPermission.createDashboard),
        isFalse,
      );
      expect(
        userHasPermission(
          userFor('Human Resources Department'),
          AppPermission.createDashboard,
        ),
        isFalse,
      );
    });
  });

  group('Create button access control on Insights screen', () {
    Future<void> loginAs(WidgetTester tester, DemoUser user) async {
      SharedPreferences.setMockInitialValues({
        'logged_in': true,
        'login_id': user.loginId,
        'department': user.department,
        'name': user.name,
        'user_id': user.userId,
      });
      await pumpThroughSplash(tester);
      await tester.pump();
    }

    testWidgets('Accounts & Finance -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Accounts & Finance'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Purchase & Procurement -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Purchase & Procurement'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Electrical -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Electrical'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Mechanical -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Mechanical'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Projects & Operations -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Projects & Operations'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Human Resources (HR) -> Create enabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Human Resources (HR)'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Administration / Back Office -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Administration / Back Office'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Management / Executive -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Management / Executive'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Vigilance -> Create disabled', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Vigilance'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Create button remains visible for every department', (WidgetTester tester) async {
      for (final DemoUser user in demoUsers) {
        await loginAs(tester, user);
        expect(find.text('Create'), findsOneWidget,
            reason: 'Create must stay visible for ${user.department}');
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('non-HR tap does not trigger Create action', (WidgetTester tester) async {
      await loginAs(tester, demoUsers.firstWhere((u) => u.department == 'Accounts & Finance'));
      final ElevatedButton button =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Create Dashboards Collection to get started'), findsOneWidget);
    });
  });
}
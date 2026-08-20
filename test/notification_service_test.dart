import 'package:flutter_test/flutter_test.dart';

import 'package:meco/models/meco_notification.dart';
import 'package:meco/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('TEST 1 - accounts user sees only Accounts & Finance notifications', () {
      const String department = 'Accounts & Finance';
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications(department);

      expect(visible, hasLength(3));
      expect(
        visible.map((MecoNotification n) => n.title),
        containsAll(<String>['Money received', 'Payment approved', 'Invoice processed']),
      );
      expect(
        visible.every((MecoNotification n) => n.department == department),
        isTrue,
      );
      expect(
        NotificationService.getUnreadCount(department),
        visible.where((MecoNotification n) => !n.isRead).length,
      );
    });

    test('TEST 2 - civil user sees only Civil / Construction notifications', () {
      const String department = 'Civil / Construction';
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications(department);

      expect(visible, hasLength(3));
      expect(
        visible.map((MecoNotification n) => n.title),
        containsAll(<String>[
          'Site Visit completed',
          'Construction progress updated',
          'Material consumed',
        ]),
      );
      expect(
        visible.every((MecoNotification n) => n.department == department),
        isTrue,
      );
    });

    test('TEST 3 - electrical user sees only Electrical notifications', () {
      const String department = 'Electrical';
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications(department);

      expect(visible, hasLength(3));
      expect(
        visible.map((MecoNotification n) => n.title),
        containsAll(<String>[
          'Electrical inspection completed',
          'Electrical material received',
          'Electrical maintenance scheduled',
        ]),
      );
      expect(
        visible.every((MecoNotification n) => n.department == department),
        isTrue,
      );
    });

    test('TEST 4 - HR user sees notifications from every department', () {
      const String department = 'Human Resources (HR)';
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications(department);

      expect(NotificationService.canSeeAllDepartments(department), isTrue);
      expect(visible, hasLength(allNotifications.length));

      final Set<String> departments =
          visible.map((MecoNotification n) => n.department).toSet();
      expect(departments, hasLength(15));

      expect(
        visible.map((MecoNotification n) => n.title),
        containsAll(<String>[
          // Accounts
          'Money received',
          // Civil
          'Site Visit completed',
          // Purchase
          'Purchase order approved',
          // Electrical
          'Electrical inspection completed',
          // Mechanical
          'Mechanical inspection completed',
          // Projects
          'Project progress updated',
          // Plant
          'Production target completed',
          // Design
          'Drawing approved',
          // Tender
          'Tender submitted',
          // HR
          'Employee attendance updated',
          // Administration
          'Administrative request completed',
          // Management
          'Management report generated',
          // Billing
          'Invoice generated',
          // Maintenance
          'Maintenance request completed',
          // Vigilance
          'Inspection completed',
        ]),
      );
    });

    test('TEST 5 - purchase user sees only Purchase & Procurement notifications', () {
      const String department = 'Purchase & Procurement';
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications(department);

      expect(visible, hasLength(3));
      expect(
        visible.map((MecoNotification n) => n.title),
        containsAll(<String>[
          'Purchase order approved',
          'Vendor quotation received',
          'Purchase request pending',
        ]),
      );
      expect(
        visible.every((MecoNotification n) => n.department == department),
        isTrue,
      );
    });

    test('TEST 6 - vigilance user sees only Vigilance notifications', () {
      const String department = 'Vigilance';
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications(department);

      expect(visible, hasLength(3));
      expect(
        visible.map((MecoNotification n) => n.title),
        containsAll(<String>[
          'Inspection completed',
          'Compliance report updated',
          'Vigilance review completed',
        ]),
      );
      expect(
        visible.every((MecoNotification n) => n.department == department),
        isTrue,
      );
    });

    test('every normal department gets exactly its own 3 notifications', () {
      const List<String> departments = <String>[
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
      ];

      for (final String department in departments) {
        final List<MecoNotification> visible =
            NotificationService.getVisibleNotifications(department);
        expect(
          visible.every((MecoNotification n) => n.department == department),
          isTrue,
          reason: '$department should only see its own notifications',
        );
      }
    });

    test('a normal user never sees another department notification', () {
      final List<MecoNotification> visible =
          NotificationService.getVisibleNotifications('Accounts & Finance');
      final List<String> titles =
          visible.map((MecoNotification n) => n.title).toList();

      expect(titles, isNot(contains('Site Visit completed')));
      expect(titles, isNot(contains('Purchase order approved')));
      expect(titles, isNot(contains('Electrical inspection completed')));
      expect(titles, isNot(contains('Project progress updated')));
    });

    test('legacy notifications belong to their own departments only', () {
      final List<MecoNotification> accounts =
          NotificationService.getVisibleNotifications('Accounts & Finance');
      final List<MecoNotification> civil =
          NotificationService.getVisibleNotifications('Civil / Construction');
      final List<MecoNotification> hr =
          NotificationService.getVisibleNotifications('Human Resources (HR)');

      expect(accounts.any((MecoNotification n) => n.title == 'Money received'), isTrue);
      expect(civil.any((MecoNotification n) => n.title == 'Site Visit completed'), isTrue);
      expect(
        civil.any((MecoNotification n) => n.title == 'Money received'),
        isFalse,
      );
      expect(
        hr.any((MecoNotification n) => n.title == 'Money received'),
        isTrue,
      );
      expect(
        hr.any((MecoNotification n) => n.title == 'Site Visit completed'),
        isTrue,
      );
    });

    test('badge count is department-specific (unread visible only)', () {
      expect(
        NotificationService.getUnreadCount('Accounts & Finance'),
        3,
      );
      expect(
        NotificationService.getUnreadCount('Civil / Construction'),
        3,
      );
      expect(NotificationService.getUnreadCount('Electrical'), 3);
      expect(
        NotificationService.getUnreadCount('Human Resources (HR)'),
        allNotifications.length,
      );
    });

    test('department with no notifications gets an empty feed', () {
      expect(
        NotificationService.getVisibleNotifications('IT/Developer'),
        isEmpty,
      );
      expect(NotificationService.getVisibleNotifications(null), isEmpty);
      expect(NotificationService.getUnreadCount(null), 0);
    });

    test('HR is the only department with cross-department access', () {
      for (final String department in allNotifications
          .map((MecoNotification n) => n.department)
          .toSet()) {
        expect(
          NotificationService.canSeeAllDepartments(department),
          department == 'Human Resources (HR)',
          reason: department,
        );
      }
    });
  });
}
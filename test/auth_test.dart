import 'package:flutter_test/flutter_test.dart';

import 'package:meco/auth/demo_users.dart';
import 'package:meco/models/demo_user.dart';

void main() {
  group('authenticate - all 15 departments succeed', () {
    const cases = [
      ('accounts@meco.com', 'Accounts & Finance', 'Accounts User', '10001'),
      (
        'administration@meco.com',
        'Administration / Back Office',
        'Administration User',
        '10002',
      ),
      ('billing@meco.com', 'Billing & Commercial', 'Billing User', '10003'),
      ('civil@meco.com', 'Civil / Construction', 'Civil User', '10004'),
      ('design@meco.com', 'Design & Technical', 'Design User', '10005'),
      ('electrical@meco.com', 'Electrical', 'Electrical User', '10006'),
      ('hr@meco.com', 'Human Resources (HR)', 'HR User', '10007'),
      ('itdev@meco.com', 'IT/Developer', 'IT User', '10016'),
      ('maintenance@meco.com', 'Maintenance', 'Maintenance User', '10008'),
      (
        'management@meco.com',
        'Management / Executive',
        'Management User',
        '10009',
      ),
      ('mechanical@meco.com', 'Mechanical', 'Mechanical User', '10010'),
      ('plant@meco.com', 'Plant / Production', 'Plant User', '10011'),
      (
        'projects@meco.com',
        'Projects & Operations',
        'Projects User',
        '10012',
      ),
      (
        'purchase@meco.com',
        'Purchase & Procurement',
        'Purchase User',
        '10013',
      ),
      (
        'tender@meco.com',
        'Tender Cell & Coordination',
        'Tender User',
        '10014',
      ),
      ('vigilance@meco.com', 'Vigilance', 'Vigilance User', '10015'),
    ];

    for (final (loginId, department, name, userId) in cases) {
      test('$loginId / 1234 / $department', () {
        final DemoUser? user = authenticate(
          loginId: loginId,
          password: '1234',
          department: department,
        );
        expect(user, isNotNull, reason: 'expected $loginId to authenticate');
        expect(user!.department, department);
        expect(user.name, name);
        expect(user.userId, userId);
      });
    }
  });

  group('authenticate - mismatches fail', () {
    test('wrong department', () {
      expect(
        authenticate(
          loginId: 'accounts@meco.com',
          password: '1234',
          department: 'Electrical',
        ),
        isNull,
      );
    });

    test('wrong password', () {
      expect(
        authenticate(
          loginId: 'accounts@meco.com',
          password: 'wrong',
          department: 'Accounts & Finance',
        ),
        isNull,
      );
    });

    test('unknown login id', () {
      expect(
        authenticate(
          loginId: 'wrong@meco.com',
          password: '1234',
          department: 'Accounts & Finance',
        ),
        isNull,
      );
    });

    test('empty login id', () {
      expect(
        authenticate(
          loginId: '',
          password: '1234',
          department: 'Accounts & Finance',
        ),
        isNull,
      );
    });

    test('no department selected', () {
      expect(
        authenticate(
          loginId: 'accounts@meco.com',
          password: '1234',
          department: null,
        ),
        isNull,
      );
    });

    test('old single-user credentials are no longer valid', () {
      expect(
        authenticate(
          loginId: 'xyz@gmail.com',
          password: '1234',
          department: 'IT/Developer',
        ),
        isNull,
      );
    });
  });

  group('getLoginIdInitial', () {
    test('uses the first letter of the login id, uppercased', () {
      expect(getLoginIdInitial('accounts@meco.com'), 'A');
      expect(getLoginIdInitial('billing@meco.com'), 'B');
      expect(getLoginIdInitial('civil@meco.com'), 'C');
      expect(getLoginIdInitial('electrical@meco.com'), 'E');
      expect(getLoginIdInitial('hr@meco.com'), 'H');
      expect(getLoginIdInitial('maintenance@meco.com'), 'M');
      expect(getLoginIdInitial('projects@meco.com'), 'P');
      expect(getLoginIdInitial('tender@meco.com'), 'T');
      expect(getLoginIdInitial('vigilance@meco.com'), 'V');
    });

    test('uppercases an already uppercase login id', () {
      expect(getLoginIdInitial('ACCOUNTS@MECO.COM'), 'A');
    });

    test('trims whitespace before taking the first letter', () {
      expect(getLoginIdInitial('  accounts@meco.com '), 'A');
    });

    test('falls back to M when the login id is empty', () {
      expect(getLoginIdInitial(''), 'M');
      expect(getLoginIdInitial('   '), 'M');
    });
  });
}
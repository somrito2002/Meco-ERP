import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meco/models/demo_user.dart';
import 'package:meco/session.dart';

void main() {
  const DemoUser user = DemoUser(
    loginId: 'accounts@meco.com',
    password: '1234',
    department: 'Accounts & Finance',
    name: 'Accounts User',
    userId: '10001',
  );

  test('Session persists and restores the authenticated user', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await Session.isLoggedIn(), isFalse);
    expect(await Session.currentUser(), isNull);

    await Session.save(user);

    expect(await Session.isLoggedIn(), isTrue);
    final DemoUser? restored = await Session.currentUser();
    expect(restored, isNotNull);
    expect(restored!.loginId, 'accounts@meco.com');
    expect(restored.department, 'Accounts & Finance');
    expect(restored.name, 'Accounts User');
    expect(restored.userId, '10001');
  });

  test('Session.clear removes the stored user', () async {
    SharedPreferences.setMockInitialValues({});
    await Session.save(user);
    await Session.clear();

    expect(await Session.isLoggedIn(), isFalse);
    expect(await Session.currentUser(), isNull);
  });
}
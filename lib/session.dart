import 'package:shared_preferences/shared_preferences.dart';

import 'models/demo_user.dart';

/// Persists the login session so a signed-in user stays signed in across
/// app restarts and does not have to log in again every time.
class Session {
  static const String _kLoggedInKey = 'logged_in';
  static const String _kLoginIdKey = 'login_id';
  static const String _kDepartmentKey = 'department';
  static const String _kNameKey = 'name';
  static const String _kUserIdKey = 'user_id';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedInKey) ?? false;
  }

  static Future<void> save(DemoUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedInKey, true);
    await prefs.setString(_kLoginIdKey, user.loginId);
    await prefs.setString(_kDepartmentKey, user.department);
    await prefs.setString(_kNameKey, user.name);
    await prefs.setString(_kUserIdKey, user.userId);
  }

  /// Restores the authenticated user from the stored session.
  /// Returns `null` when no complete session exists.
  static Future<DemoUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loginId = prefs.getString(_kLoginIdKey);
    final String? department = prefs.getString(_kDepartmentKey);
    final String? name = prefs.getString(_kNameKey);
    final String? userId = prefs.getString(_kUserIdKey);
    if (loginId == null || department == null || name == null || userId == null) {
      return null;
    }
    return DemoUser(
      loginId: loginId,
      password: '',
      department: department,
      name: name,
      userId: userId,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInKey);
    await prefs.remove(_kLoginIdKey);
    await prefs.remove(_kDepartmentKey);
    await prefs.remove(_kNameKey);
    await prefs.remove(_kUserIdKey);
  }
}
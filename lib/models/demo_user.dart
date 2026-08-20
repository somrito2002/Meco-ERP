/// Temporary user model for development/testing authentication.
///
/// Later this will be replaced by real backend user data.
class DemoUser {
  final String loginId;
  final String password;
  final String department;
  final String name;
  final String userId;

  const DemoUser({
    required this.loginId,
    required this.password,
    required this.department,
    required this.name,
    required this.userId,
  });
}

/// First letter of the authenticated user's Login ID (email), uppercased.
///
/// The avatar letter is always derived from the Login ID, never from the
/// department or display name. Falls back to 'M' when the ID is empty.
String getLoginIdInitial(String loginId) {
  final String value = loginId.trim();

  if (value.isEmpty) {
    return 'M';
  }

  return value.substring(0, 1).toUpperCase();
}
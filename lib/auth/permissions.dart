import '../models/demo_user.dart';

/// Application-level permissions that can be granted per user/department.
///
/// Kept as a single enum so new permissions can be added later without
/// touching call sites.
enum AppPermission {
  createDashboard,
}

/// Whether the authenticated [user] holds [permission].
///
/// Permission rules are department-based for now. The department string is
/// the source of truth (never derived from the login ID/email).
bool userHasPermission(DemoUser user, AppPermission permission) {
  switch (permission) {
    case AppPermission.createDashboard:
      return _isHr(user.department);
  }
}

/// Matches the existing HR department string robustly.
///
/// The canonical value used by the auth system is `Human Resources (HR)`.
/// `HR` is accepted as a shorthand alias. Comparison is case-insensitive
/// and trims surrounding whitespace, but never grants unrelated departments
/// whose names merely contain similar text.
bool _isHr(String department) {
  const Set<String> hrDepartments = {
    'human resources (hr)',
    'hr',
  };
  return hrDepartments.contains(department.trim().toLowerCase());
}
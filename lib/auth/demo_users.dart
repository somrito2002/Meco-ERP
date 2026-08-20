import '../models/demo_user.dart';

/// TEMPORARY hardcoded demo credentials for development/testing only.
///
/// All 15 users share the password `1234` intentionally. This list is the
/// single source of truth for department login and will be replaced by real
/// backend authentication later.
const List<DemoUser> demoUsers = [
  DemoUser(
    loginId: 'accounts@meco.com',
    password: '1234',
    department: 'Accounts & Finance',
    name: 'Accounts User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'administration@meco.com',
    password: '1234',
    department: 'Administration / Back Office',
    name: 'Administration User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'billing@meco.com',
    password: '1234',
    department: 'Billing & Commercial',
    name: 'Billing User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'civil@meco.com',
    password: '1234',
    department: 'Civil / Construction',
    name: 'Civil User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'design@meco.com',
    password: '1234',
    department: 'Design & Technical',
    name: 'Design User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'electrical@meco.com',
    password: '1234',
    department: 'Electrical',
    name: 'Electrical User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'hr@meco.com',
    password: '1234',
    department: 'Human Resources (HR)',
    name: 'HR User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'itdev@meco.com',
    password: '1234',
    department: 'IT/Developer',
    name: 'IT User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'maintenance@meco.com',
    password: '1234',
    department: 'Maintenance',
    name: 'Maintenance User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'management@meco.com',
    password: '1234',
    department: 'Management / Executive',
    name: 'Management User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'mechanical@meco.com',
    password: '1234',
    department: 'Mechanical',
    name: 'Mechanical User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'plant@meco.com',
    password: '1234',
    department: 'Plant / Production',
    name: 'Plant User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'projects@meco.com',
    password: '1234',
    department: 'Projects & Operations',
    name: 'Projects User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'purchase@meco.com',
    password: '1234',
    department: 'Purchase & Procurement',
    name: 'Purchase User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'tender@meco.com',
    password: '1234',
    department: 'Tender Cell & Coordination',
    name: 'Tender User',
    userId: 'xx',
  ),
  DemoUser(
    loginId: 'vigilance@meco.com',
    password: '1234',
    department: 'Vigilance',
    name: 'Vigilance User',
    userId: 'xx',
  ),
];

/// TEMPORARY authentication service.
///
/// A login succeeds only when the Login ID, Password, and Department all
/// match one of the [demoUsers]. Returns `null` otherwise, without revealing
/// which credential was wrong.
///
/// Replace this function with a backend API call later.
DemoUser? authenticate({
  required String loginId,
  required String password,
  required String? department,
}) {
  for (final DemoUser user in demoUsers) {
    if (user.loginId == loginId &&
        user.password == password &&
        user.department == department) {
      return user;
    }
  }
  return null;
}
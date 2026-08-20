import '../models/meco_notification.dart';

/// Central dummy notification feed (development/demo only).
///
/// This is the SINGLE source of truth for notifications; screens must never
/// define their own notification lists. It will be replaced by the backend
/// feed later — the same department permission rule must then be enforced
/// server-side too (normal users: own department only; HR: all departments).
final List<MecoNotification> allNotifications = <MecoNotification>[
  // ── Accounts & Finance ──────────────────────────────────────────────────
  MecoNotification(
    id: 'accounts_001',
    title: 'Money received',
    description: 'A payment has been received.',
    department: 'Accounts & Finance',
    timestamp: DateTime.now().subtract(const Duration(minutes: 60)),
    isRead: false,
  ),
  MecoNotification(
    id: 'accounts_002',
    title: 'Payment approved',
    description: 'A payment has been approved.',
    department: 'Accounts & Finance',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: false,
  ),
  MecoNotification(
    id: 'accounts_003',
    title: 'Invoice processed',
    description: 'An invoice has been processed.',
    department: 'Accounts & Finance',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),

  // ── Purchase & Procurement ──────────────────────────────────────────────
  MecoNotification(
    id: 'purchase_001',
    title: 'Purchase order approved',
    description: 'A purchase order has been approved.',
    department: 'Purchase & Procurement',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    isRead: false,
  ),
  MecoNotification(
    id: 'purchase_002',
    title: 'Vendor quotation received',
    description: 'A vendor quotation has been received.',
    department: 'Purchase & Procurement',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
  ),
  MecoNotification(
    id: 'purchase_003',
    title: 'Purchase request pending',
    description: 'A purchase request is pending approval.',
    department: 'Purchase & Procurement',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
  ),

  // ── Civil / Construction ────────────────────────────────────────────────
  MecoNotification(
    id: 'civil_001',
    title: 'Site Visit completed',
    description: 'The scheduled site visit has been completed.',
    department: 'Civil / Construction',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    isRead: false,
  ),
  MecoNotification(
    id: 'civil_002',
    title: 'Construction progress updated',
    description: 'Construction progress has been updated.',
    department: 'Civil / Construction',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: false,
  ),
  MecoNotification(
    id: 'civil_003',
    title: 'Material consumed',
    description: 'Material consumption has been recorded.',
    department: 'Civil / Construction',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),

  // ── Electrical ──────────────────────────────────────────────────────────
  MecoNotification(
    id: 'electrical_001',
    title: 'Electrical inspection completed',
    description: 'The electrical inspection has been completed.',
    department: 'Electrical',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isRead: false,
  ),
  MecoNotification(
    id: 'electrical_002',
    title: 'Electrical material received',
    description: 'Electrical material has been received.',
    department: 'Electrical',
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    isRead: false,
  ),
  MecoNotification(
    id: 'electrical_003',
    title: 'Electrical maintenance scheduled',
    description: 'Electrical maintenance has been scheduled.',
    department: 'Electrical',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
  ),

  // ── Mechanical ──────────────────────────────────────────────────────────
  MecoNotification(
    id: 'mechanical_001',
    title: 'Mechanical inspection completed',
    description: 'The mechanical inspection has been completed.',
    department: 'Mechanical',
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    isRead: false,
  ),
  MecoNotification(
    id: 'mechanical_002',
    title: 'Equipment maintenance completed',
    description: 'Equipment maintenance has been completed.',
    department: 'Mechanical',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    isRead: false,
  ),
  MecoNotification(
    id: 'mechanical_003',
    title: 'Machine service scheduled',
    description: 'Machine service has been scheduled.',
    department: 'Mechanical',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    isRead: false,
  ),

  // ── Projects & Operations ───────────────────────────────────────────────
  MecoNotification(
    id: 'projects_001',
    title: 'Project progress updated',
    description: 'Project progress has been updated.',
    department: 'Projects & Operations',
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    isRead: false,
  ),
  MecoNotification(
    id: 'projects_002',
    title: 'Operation task completed',
    description: 'An operation task has been completed.',
    department: 'Projects & Operations',
    timestamp: DateTime.now().subtract(const Duration(hours: 7)),
    isRead: false,
  ),
  MecoNotification(
    id: 'projects_003',
    title: 'Project milestone reached',
    description: 'A project milestone has been reached.',
    department: 'Projects & Operations',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),

  // ── Plant / Production ──────────────────────────────────────────────────
  MecoNotification(
    id: 'plant_001',
    title: 'Production target completed',
    description: 'The production target has been completed.',
    department: 'Plant / Production',
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    isRead: false,
  ),
  MecoNotification(
    id: 'plant_002',
    title: 'Production report generated',
    description: 'The production report has been generated.',
    department: 'Plant / Production',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    isRead: false,
  ),
  MecoNotification(
    id: 'plant_003',
    title: 'Material production updated',
    description: 'Material production has been updated.',
    department: 'Plant / Production',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
  ),

  // ── Design & Technical ──────────────────────────────────────────────────
  MecoNotification(
    id: 'design_001',
    title: 'Drawing approved',
    description: 'A drawing has been approved.',
    department: 'Design & Technical',
    timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    isRead: false,
  ),
  MecoNotification(
    id: 'design_002',
    title: 'Technical document uploaded',
    description: 'A technical document has been uploaded.',
    department: 'Design & Technical',
    timestamp: DateTime.now().subtract(const Duration(hours: 9)),
    isRead: false,
  ),
  MecoNotification(
    id: 'design_003',
    title: 'Design revision completed',
    description: 'A design revision has been completed.',
    department: 'Design & Technical',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),

  // ── Tender Cell & Coordination ──────────────────────────────────────────
  MecoNotification(
    id: 'tender_001',
    title: 'Tender submitted',
    description: 'A tender has been submitted.',
    department: 'Tender Cell & Coordination',
    timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    isRead: false,
  ),
  MecoNotification(
    id: 'tender_002',
    title: 'Tender deadline approaching',
    description: 'A tender deadline is approaching.',
    department: 'Tender Cell & Coordination',
    timestamp: DateTime.now().subtract(const Duration(hours: 10)),
    isRead: false,
  ),
  MecoNotification(
    id: 'tender_003',
    title: 'Tender document updated',
    description: 'A tender document has been updated.',
    department: 'Tender Cell & Coordination',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    isRead: false,
  ),

  // ── Human Resources (HR) ────────────────────────────────────────────────
  MecoNotification(
    id: 'hr_001',
    title: 'Employee attendance updated',
    description: 'Employee attendance has been updated.',
    department: 'Human Resources (HR)',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    isRead: false,
  ),
  MecoNotification(
    id: 'hr_002',
    title: 'Leave request submitted',
    description: 'A leave request has been submitted.',
    department: 'Human Resources (HR)',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: false,
  ),
  MecoNotification(
    id: 'hr_003',
    title: 'New employee added',
    description: 'A new employee has been added.',
    department: 'Human Resources (HR)',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
  ),

  // ── Administration / Back Office ────────────────────────────────────────
  MecoNotification(
    id: 'administration_001',
    title: 'Administrative request completed',
    description: 'An administrative request has been completed.',
    department: 'Administration / Back Office',
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    isRead: false,
  ),
  MecoNotification(
    id: 'administration_002',
    title: 'Office document received',
    description: 'An office document has been received.',
    department: 'Administration / Back Office',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: false,
  ),
  MecoNotification(
    id: 'administration_003',
    title: 'Administration task completed',
    description: 'An administration task has been completed.',
    department: 'Administration / Back Office',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),

  // ── Management / Executive ──────────────────────────────────────────────
  MecoNotification(
    id: 'management_001',
    title: 'Management report generated',
    description: 'A management report has been generated.',
    department: 'Management / Executive',
    timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
    isRead: false,
  ),
  MecoNotification(
    id: 'management_002',
    title: 'Executive review completed',
    description: 'An executive review has been completed.',
    department: 'Management / Executive',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: false,
  ),
  MecoNotification(
    id: 'management_003',
    title: 'Business update available',
    description: 'A business update is available.',
    department: 'Management / Executive',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
  ),

  // ── Billing & Commercial ────────────────────────────────────────────────
  MecoNotification(
    id: 'billing_001',
    title: 'Invoice generated',
    description: 'An invoice has been generated.',
    department: 'Billing & Commercial',
    timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
    isRead: false,
  ),
  MecoNotification(
    id: 'billing_002',
    title: 'Client payment received',
    description: 'A client payment has been received.',
    department: 'Billing & Commercial',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    isRead: false,
  ),
  MecoNotification(
    id: 'billing_003',
    title: 'Billing report completed',
    description: 'The billing report has been completed.',
    department: 'Billing & Commercial',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),

  // ── Maintenance ─────────────────────────────────────────────────────────
  MecoNotification(
    id: 'maintenance_001',
    title: 'Maintenance request completed',
    description: 'A maintenance request has been completed.',
    department: 'Maintenance',
    timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
    isRead: false,
  ),
  MecoNotification(
    id: 'maintenance_002',
    title: 'Equipment service scheduled',
    description: 'Equipment service has been scheduled.',
    department: 'Maintenance',
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    isRead: false,
  ),
  MecoNotification(
    id: 'maintenance_003',
    title: 'Maintenance report generated',
    description: 'The maintenance report has been generated.',
    department: 'Maintenance',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
  ),

  // ── Vigilance ───────────────────────────────────────────────────────────
  MecoNotification(
    id: 'vigilance_001',
    title: 'Inspection completed',
    description: 'An inspection has been completed.',
    department: 'Vigilance',
    timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
    isRead: false,
  ),
  MecoNotification(
    id: 'vigilance_002',
    title: 'Compliance report updated',
    description: 'The compliance report has been updated.',
    department: 'Vigilance',
    timestamp: DateTime.now().subtract(const Duration(hours: 7)),
    isRead: false,
  ),
  MecoNotification(
    id: 'vigilance_003',
    title: 'Vigilance review completed',
    description: 'A vigilance review has been completed.',
    department: 'Vigilance',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),
];

/// Central notification permission/filtering service (development/demo).
///
/// Business rule: a normal department user may see ONLY their own
/// department's notifications; the HR department may see ALL of them.
///
/// UI widgets must consume the results of [getVisibleNotifications] /
/// [getUnreadCount] instead of re-implementing department checks.
class NotificationService {
  /// Department with access to every department's notifications.
  static const String hrDepartment = 'Human Resources (HR)';

  /// Whether [userDepartment] can see notifications from all departments.
  static bool canSeeAllDepartments(String? userDepartment) {
    return userDepartment == hrDepartment;
  }

  /// Returns the notifications visible to the given user department.
  ///
  /// HR gets the whole feed; every other department gets only the
  /// notifications that belong to it.
  static List<MecoNotification> getVisibleNotifications(
    String? userDepartment, {
    List<MecoNotification>? source,
  }) {
    final List<MecoNotification> feed = source ?? allNotifications;

    if (canSeeAllDepartments(userDepartment)) {
      return List<MecoNotification>.of(feed);
    }

    return feed
        .where((MecoNotification n) => n.department == userDepartment)
        .toList();
  }

  /// Number of unread notifications visible to [userDepartment].
  static int getUnreadCount(
    String? userDepartment, {
    List<MecoNotification>? source,
  }) {
    return getVisibleNotifications(userDepartment, source: source)
        .where((MecoNotification n) => !n.isRead)
        .length;
  }
}
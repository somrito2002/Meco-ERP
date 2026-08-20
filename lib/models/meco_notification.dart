/// A single notification shown in the Meco app.
///
/// [department] is the owning department and the key field for visibility:
/// a normal department user may only see notifications whose [department]
/// matches their own, while HR may see all of them.
///
/// This model mirrors the shape a future backend notification record will
/// have, so the same permission rule can be enforced server-side later.
class MecoNotification {
  final String id;
  final String title;
  final String description;
  final String department;
  final DateTime timestamp;
  final bool isRead;

  const MecoNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.timestamp,
    required this.isRead,
  });

  /// Returns a copy with the given fields replaced.
  MecoNotification copyWith({bool? isRead}) {
    return MecoNotification(
      id: id,
      title: title,
      description: description,
      department: department,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
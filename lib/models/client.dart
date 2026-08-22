class Client {
  final int serialNumber;
  final String organisationName;
  final String primaryUser;
  final String inviteStatus;
  final String status;

  const Client({
    required this.serialNumber,
    required this.organisationName,
    required this.primaryUser,
    required this.inviteStatus,
    required this.status,
  });
}

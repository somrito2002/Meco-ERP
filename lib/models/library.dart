/// A single element-library record shown on the Libraries screen.
///
/// Data-driven model so the sample list can later be replaced with
/// backend/database records without changing the UI code.
class Library {
  final int serialNumber;
  final String name;
  final String type;
  final String createdBy;
  final String lastUpdated;
  final int sections;
  final int elements;

  const Library({
    required this.serialNumber,
    required this.name,
    required this.type,
    required this.createdBy,
    required this.lastUpdated,
    required this.sections,
    required this.elements,
  });
}

/// A single element record shown in the All Elements table.
///
/// Data-driven model so the (currently empty) list can later be replaced
/// with backend/database records without changing the UI code.
class ElementItem {
  final String itemName;
  final String itemDescription;
  final String libraryName;
  final String sectionName;
  final String brand;
  final String itemCode;
  final String category;
  final String itemType;
  final double serviceCharge;
  final double discount;
  final String hsn;
  final double gst;
  final String uom;
  final double standardQuantity;

  const ElementItem({
    required this.itemName,
    this.itemDescription = '',
    required this.libraryName,
    required this.sectionName,
    required this.brand,
    this.itemCode = '',
    this.category = '',
    this.itemType = '',
    this.serviceCharge = 0.0,
    this.discount = 0.0,
    this.hsn = '',
    this.gst = 0.0,
    required this.uom,
    required this.standardQuantity,
  });
}

class ReportModel {
  final String id;
  final String type; // "স্বর্ণ হিসাব", "যাকাত হিসাব", "রৌপ্য হিসাব"
  final String item;
  final String date;
  final String value;

  ReportModel({
    required this.id,
    required this.type,
    required this.item,
    required this.date,
    required this.value,
  });
}

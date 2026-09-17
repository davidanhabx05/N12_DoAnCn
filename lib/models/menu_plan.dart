class MenuPlan {
  final String id;
  final String title;
  final DateTime date;
  final String status; // e.g., "active", "draft", "history"
  final List<String> dishIds;

  MenuPlan({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.dishIds,
  });
}

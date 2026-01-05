class AiSuggestRequest {
  AiSuggestRequest({
    required this.type,
    required this.note,
    required this.categories,
  });

  final int type; // 0 expense, 1 income
  final String note;
  final List<Map<String, String>> categories; // [{id,name},...]

  Map<String, dynamic> toJson() => {
        'type': type,
        'note': note,
        'categories': categories,
      };
}

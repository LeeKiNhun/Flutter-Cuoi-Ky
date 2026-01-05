class AiSuggestResponse {
  AiSuggestResponse({
    required this.categoryId,
    required this.confidence,
    required this.reason,
  });

  final String categoryId;
  final double confidence;
  final String reason;

  factory AiSuggestResponse.fromJson(Map<String, dynamic> json) {
    return AiSuggestResponse(
      categoryId: json['categoryId'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reason: (json['reason'] as String?) ?? '',
    );
  }
}

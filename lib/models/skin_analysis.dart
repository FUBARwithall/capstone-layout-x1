class SkinAnalysis {
  final double score;
  final String status;
  final String triggers;

  SkinAnalysis({
    required this.score,
    required this.status,
    required this.triggers,
  });

  factory SkinAnalysis.fromJson(Map<String, dynamic> json) {
    return SkinAnalysis(
      score: json['skin_load_score'].toDouble(),
      status: json['status'],
      triggers: json['main_triggers'],
    );
  }
}

// Phase 2 — P2-03 Transparent Personalized Recommendations
// RecommendationResult holds the score breakdown so users can follow each factor.
// Scoring is fully deterministic — same inputs always yield same outputs.
// No ML/AI. Formula documented in docs/decisions-log.md (ADR-P2-003).

class RecommendationFactor {
  /// Human-readable factor name, e.g. "Discipline Match".
  final String name;

  /// Score contribution, 0.0–1.0.
  final double score;

  /// Maximum possible score for this factor.
  final double maxScore;

  /// Explanation of why this score was awarded.
  final String explanation;

  const RecommendationFactor({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.explanation,
  });
}

class RecommendationResult {
  final String institutionId;
  final String institutionName;

  /// Total weighted score 0.0–100.0.
  final double totalScore;

  /// Ordered list of factor breakdowns for transparency.
  final List<RecommendationFactor> factors;

  /// Badge label shown to user, e.g. "Strong Match".
  final String matchLabel;

  const RecommendationResult({
    required this.institutionId,
    required this.institutionName,
    required this.totalScore,
    required this.factors,
    required this.matchLabel,
  });
}

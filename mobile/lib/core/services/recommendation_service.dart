// Phase 2 — P2-03 Transparent Personalized Recommendations Engine
// Deterministic, explainable scoring formula without black-box ML or AI hallucination.
// Documented in docs/decisions-log.md (ADR-P2-003).

import '../models/institution.dart';
import '../models/programme.dart';
import '../models/eligibility_rule.dart';
import '../models/recommendation_result.dart';

class RecommendationService {
  /// Computes personalized, transparent match rankings for institutions
  /// based on student profile preferences and academic aggregate.
  List<RecommendationResult> rankInstitutions({
    required List<Institution> institutions,
    required List<Programme> programmes,
    required List<EligibilityRule> eligibilityRules,
    required Map<String, dynamic> studentProfile,
  }) {
    final targetDiscipline = (studentProfile['target_discipline'] as String?)?.trim().toLowerCase();
    final targetDegreeLevel = (studentProfile['target_degree_level'] as String?)?.trim().toLowerCase();
    final preferredCityId = (studentProfile['preferred_city_id'] as String?)?.trim().toLowerCase();
    final academicPercentage = (studentProfile['academic_percentage'] as num?)?.toDouble();

    final results = <RecommendationResult>[];

    for (final inst in institutions) {
      final instProgrammes = programmes.where((p) => p.institutionId == inst.id).toList();
      final factors = <RecommendationFactor>[];

      // 1. Discipline Alignment (Weight: 35 max)
      double disciplineScore = 0.0;
      String disciplineExp;
      if (targetDiscipline == null || targetDiscipline.isEmpty) {
        disciplineScore = 20.0; // neutral default when user hasn't specified
        disciplineExp = 'No specific discipline preferred; standard baseline awarded.';
      } else {
        final matches = instProgrammes.where((p) =>
            p.disciplineId.toLowerCase().contains(targetDiscipline) ||
            p.name.toLowerCase().contains(targetDiscipline)).toList();
        if (matches.isNotEmpty) {
          disciplineScore = 35.0;
          disciplineExp = 'Offers ${matches.length} programme(s) aligned with your interest in ${studentProfile['target_discipline']}.';
        } else {
          disciplineScore = 5.0;
          disciplineExp = 'No published programmes directly matching ${studentProfile['target_discipline']}.';
        }
      }
      factors.add(RecommendationFactor(
        name: 'Discipline Alignment',
        score: disciplineScore,
        maxScore: 35.0,
        explanation: disciplineExp,
      ));

      // 2. Degree Level Availability (Weight: 25 max)
      double degreeScore = 0.0;
      String degreeExp;
      if (targetDegreeLevel == null || targetDegreeLevel.isEmpty) {
        degreeScore = 15.0;
        degreeExp = 'No target degree level selected; standard baseline awarded.';
      } else {
        final hasLevel = instProgrammes.any((p) => p.degreeLevel.toLowerCase() == targetDegreeLevel);
        if (hasLevel) {
          degreeScore = 25.0;
          degreeExp = 'Offers active degree programmes at your requested level (${studentProfile['target_degree_level']}).';
        } else {
          degreeScore = 0.0;
          degreeExp = 'Does not currently list published degrees at your requested level (${studentProfile['target_degree_level']}).';
        }
      }
      factors.add(RecommendationFactor(
        name: 'Degree Level Availability',
        score: degreeScore,
        maxScore: 25.0,
        explanation: degreeExp,
      ));

      // 3. Location / Preferred City Match (Weight: 20 max)
      double locationScore = 0.0;
      String locationExp;
      if (preferredCityId == null || preferredCityId.isEmpty) {
        locationScore = 10.0;
        locationExp = 'No city preference specified.';
      } else if (inst.cityId?.toLowerCase() == preferredCityId) {
        locationScore = 20.0;
        locationExp = 'Located in your preferred target city.';
      } else {
        locationScore = 0.0;
        locationExp = 'Located outside your specified preferred city.';
      }
      factors.add(RecommendationFactor(
        name: 'Location Match',
        score: locationScore,
        maxScore: 20.0,
        explanation: locationExp,
      ));

      // 4. Academic Baseline Compatibility (Weight: 20 max)
      double academicScore = 0.0;
      String academicExp;
      if (academicPercentage == null) {
        academicScore = 10.0;
        academicExp = 'Enter your academic percentage in Profile to unlock precise eligibility matching.';
      } else {
        // Evaluate against programmes offered by this institution
        final rules = eligibilityRules.where((r) =>
            instProgrammes.any((p) => p.id == r.programmeId)).toList();
        if (rules.isEmpty) {
          academicScore = 12.0;
          academicExp = 'Programme criteria are qualitative or pending portal review.';
        } else {
          final eligibleCount = rules.where((r) =>
              r.minPercentage == null || academicPercentage >= r.minPercentage!).length;
          final ratio = eligibleCount / rules.length;
          academicScore = (ratio * 20.0).clamp(0.0, 20.0);
          if (ratio >= 0.8) {
            academicExp = 'Your score of ${academicPercentage.toStringAsFixed(1)}% satisfies baseline thresholds for ${rules.length} programme(s).';
          } else {
            academicExp = 'Satisfies baseline requirements for $eligibleCount of ${rules.length} evaluated programme(s).';
          }
        }
      }
      factors.add(RecommendationFactor(
        name: 'Academic Baseline Compatibility',
        score: academicScore,
        maxScore: 20.0,
        explanation: academicExp,
      ));

      // Calculate Total Score & Determine Match Label
      final totalScore = factors.fold<double>(0.0, (sum, f) => sum + f.score);
      String matchLabel;
      if (totalScore >= 75.0) {
        matchLabel = 'Strong Match';
      } else if (totalScore >= 50.0) {
        matchLabel = 'Good Match';
      } else if (totalScore >= 30.0) {
        matchLabel = 'Potential Option';
      } else {
        matchLabel = 'Exploratory';
      }

      results.add(RecommendationResult(
        institutionId: inst.id,
        institutionName: inst.name,
        totalScore: totalScore,
        factors: factors,
        matchLabel: matchLabel,
      ));
    }

    // Sort descending by total score, then alphabetically by institution name for determinism
    results.sort((a, b) {
      final cmp = b.totalScore.compareTo(a.totalScore);
      if (cmp != 0) return cmp;
      return a.institutionName.compareTo(b.institutionName);
    });

    return results;
  }
}

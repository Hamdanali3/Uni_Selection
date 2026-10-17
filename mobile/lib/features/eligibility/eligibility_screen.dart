import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/programme.dart';
import '../../core/models/eligibility_rule.dart';

class EligibilityScreen extends StatefulWidget {
  final UniSelectionRepository repository;
  final String? initialProgrammeId;

  const EligibilityScreen({
    super.key,
    required this.repository,
    this.initialProgrammeId,
  });

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final TextEditingController _scoreController = TextEditingController();
  String? _selectedProgrammeId;
  EligibilityResult? _evaluationResult;

  @override
  void initState() {
    super.initState();
    final allProgrammes = widget.repository.programmes;
    if (widget.initialProgrammeId != null &&
        allProgrammes.any((p) => p.id == widget.initialProgrammeId)) {
      _selectedProgrammeId = widget.initialProgrammeId;
    } else if (allProgrammes.isNotEmpty) {
      _selectedProgrammeId = allProgrammes.first.id;
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _evaluate() {
    final scoreText = _scoreController.text.trim();
    final score = double.tryParse(scoreText);

    if (score == null || score < 0 || score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid academic percentage between 0 and 100.')),
      );
      return;
    }

    if (_selectedProgrammeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a programme to evaluate.')),
      );
      return;
    }

    final rule = widget.repository.getEligibilityRuleForProgramme(_selectedProgrammeId!);
    if (rule != null) {
      setState(() {
        _evaluationResult = rule.evaluate(score);
      });
    } else {
      final prog = widget.repository.getProgrammeById(_selectedProgrammeId!);
      setState(() {
        _evaluationResult = EligibilityResult(
          status: EligibilityStatus.requiresVerification,
          title: 'Check Official Admissions Portal',
          message: 'No automated rule is registered for this degree. Please consult the published criteria.',
          rule: EligibilityRule(
            id: 'placeholder',
            programmeId: _selectedProgrammeId!,
            ruleType: 'qualitative',
            ruleExplanation: 'Programme requirements require manual verification on the university portal.',
            caveat: 'Guidance only based on published university rules. Admission is competitive.',
            effectiveSession: '2025-2026',
            sourceUrl: prog?.officialUrl ?? '',
            lastVerifiedAt: DateTime.now().toIso8601String().substring(0, 10),
          ),
        );
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProgrammes = widget.repository.programmes;

    Programme? currentProgramme;
    if (_selectedProgrammeId != null) {
      currentProgramme = widget.repository.getProgrammeById(_selectedProgrammeId!);
    }
    final currentRule = _selectedProgrammeId != null
        ? widget.repository.getEligibilityRuleForProgramme(_selectedProgrammeId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eligibility Guidance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner explaining rule-based guidance
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Evaluated strictly against published institutional criteria. No admission guarantee.',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Programme Selector Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Target Degree Programme:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: allProgrammes.any((p) => p.id == _selectedProgrammeId)
                      ? _selectedProgrammeId
                      : (allProgrammes.isNotEmpty ? allProgrammes.first.id : null),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: allProgrammes.map((prog) {
                    final inst = widget.repository.getInstitutionById(prog.institutionId);
                    return DropdownMenuItem<String>(
                      value: prog.id,
                      child: Text(
                        '${prog.name} (${inst?.shortName ?? inst?.name ?? ""})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProgrammeId = val;
                      _evaluationResult = null;
                    });
                  },
                ),
                if (currentRule != null) ...[
                  const SizedBox(height: 10),
                  if (currentRule.minPercentage != null) ...[
                    Text(
                      'Published Baseline: Minimum ${currentRule.minPercentage!.toStringAsFixed(0)}% in ${currentRule.requiredSubjects ?? "prescribed subjects"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                    ),
                  ] else ...[
                    Text(
                      'Published Baseline: ${currentRule.requiredSubjects ?? "Qualitative & Entrance Assessment"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Student Marks Input Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Academic Aggregate Percentage (%):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your intermediate (F.Sc / A-Level equivalent / Matric) percentage.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _scoreController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 68.5',
                    suffixText: '%',
                    prefixIcon: Icon(Icons.percent_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _evaluate,
                    child: const Text('Evaluate Eligibility'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Evaluation Result Display
          if (_evaluationResult != null) ...[
            _buildResultCard(_evaluationResult!, currentProgramme),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(EligibilityResult result, Programme? prog) {
    Color bannerColor;
    Color textColor;
    IconData icon;

    switch (result.status) {
      case EligibilityStatus.eligible:
        bannerColor = AppColors.secondaryContainer;
        textColor = const Color(0xFF0F766E);
        icon = Icons.check_circle_rounded;
        break;
      case EligibilityStatus.belowMinimum:
        bannerColor = AppColors.tertiaryContainer;
        textColor = const Color(0xFFB45309);
        icon = Icons.warning_amber_rounded;
        break;
      case EligibilityStatus.requiresVerification:
        bannerColor = AppColors.surfaceVariant;
        textColor = AppColors.textPrimary;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.message,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
          ),
          const Divider(height: 20),
          const Text(
            'Published Rule Details:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            result.rule.ruleExplanation,
            style: const TextStyle(fontSize: 12.5, height: 1.35),
          ),
          const SizedBox(height: 12),
          // Caveat
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.gavel_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    result.rule.caveat,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (result.rule.sourceUrl.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => _launchUrl(result.rule.sourceUrl),
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('Open Official Admissions Criteria Page'),
            ),
          ],
        ],
      ),
    );
  }
}

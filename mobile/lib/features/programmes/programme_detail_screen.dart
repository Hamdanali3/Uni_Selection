import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/programme.dart';
import '../../core/models/institution.dart';
import '../eligibility/eligibility_screen.dart';

class ProgrammeDetailScreen extends StatelessWidget {
  final Programme programme;
  final Institution institution;
  final UniSelectionRepository repository;

  const ProgrammeDetailScreen({
    super.key,
    required this.programme,
    required this.institution,
    required this.repository,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final discipline = repository.getDiscipline(programme.disciplineId);
    final rule = repository.getEligibilityRuleForProgramme(programme.id);
    final fee = repository.getFeeRecordForProgramme(programme.id);
    final isShortlisted = repository.isProgrammeShortlisted(programme.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(programme.name),
        actions: [
          IconButton(
            icon: Icon(
              isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isShortlisted ? AppColors.secondary : null,
            ),
            onPressed: () {
              repository.toggleProgrammeShortlist(programme.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _launchUrl(context, programme.officialUrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        programme.degreeLevel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      discipline?.name ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  programme.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Offered by: ${institution.name}',
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Duration', '${programme.durationYears.toStringAsFixed(0)} Years'),
                    _buildStatItem('Mode', programme.studyMode),
                    _buildStatItem('Audited', programme.lastVerifiedAt),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Published Eligibility Requirements Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fact_check_outlined, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Published Eligibility Requirements',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (rule != null) ...[
                  if (rule.minPercentage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF0F766E), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Minimum Academic Aggregate: ${rule.minPercentage!.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (rule.requiredSubjects != null) ...[
                    const Text(
                      'Prerequisite Subjects:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 3),
                    Text(rule.requiredSubjects!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),
                  ],
                  if (rule.acceptedEntryTests != null) ...[
                    const Text(
                      'Accepted Entrance / Standardized Tests:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 3),
                    Text(rule.acceptedEntryTests!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    rule.ruleExplanation,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  // Mandatory Legal Caveat
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rule.caveat,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text(
                    'No automated eligibility rules encoded for this specific programme. Please refer directly to the official university admissions criteria.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 14),
                // Button to check eligibility
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EligibilityScreen(
                            repository: repository,
                            initialProgrammeId: programme.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Check My Eligibility for this Degree'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fee Structure Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, color: AppColors.tertiary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Published Fee Schedule',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (fee != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tuition Fee (${fee.billingBasis}):',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${fee.currency} ${fee.tuitionFee.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (fee.admissionFeeOnetime > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('One-Time Admission Dues:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('${fee.currency} ${fee.admissionFeeOnetime.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  if (fee.securityDeposit > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Refundable Security Deposit:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('${fee.currency} ${fee.securityDeposit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  if (fee.notes != null) ...[
                    const Divider(height: 20),
                    Text(
                      fee.notes!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Effective Session: ${fee.academicSession} • Last Audited: ${fee.lastVerifiedAt}',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  ),
                ] else ...[
                  const Text(
                    'Fee structure under verification for this academic session. Check the official prospectus below.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Official Prospectus Link Button
          OutlinedButton.icon(
            onPressed: () => _launchUrl(context, programme.officialUrl),
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('View Official Programme Prospectus'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

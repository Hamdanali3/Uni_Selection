// Phase 2 — P2-01 Scholarship Detail Screen
// Displays verified scholarship details, coverage, structured criteria,
// official source links, deadline reminder scheduling, and discrepancy reporting.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/scholarship.dart';
import '../../core/repositories/uniselection_repository.dart';

class ScholarshipDetailScreen extends StatefulWidget {
  final Scholarship scholarship;
  final UniSelectionRepository repository;

  const ScholarshipDetailScreen({
    super.key,
    required this.scholarship,
    required this.repository,
  });

  @override
  State<ScholarshipDetailScreen> createState() => _ScholarshipDetailScreenState();
}

class _ScholarshipDetailScreenState extends State<ScholarshipDetailScreen> {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openDiscrepancyDialog() {
    final fieldController = TextEditingController(text: 'Coverage / Criteria');
    final valController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Scholarship Discrepancy', style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help verify scholarship accuracy. Our editorial team reviews every report against official university sources.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fieldController,
                decoration: const InputDecoration(labelText: 'Field with Discrepancy'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valController,
                decoration: const InputDecoration(labelText: 'Correct Value (or Official URL)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes / Explanation'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (valController.text.trim().isNotEmpty) {
                await widget.repository.submitUserDiscrepancyReport(
                  entityId: widget.scholarship.id,
                  entityType: 'scholarship',
                  fieldName: fieldController.text.trim(),
                  reportedValue: valController.text.trim(),
                  notes: notesController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Discrepancy submitted for editorial verification.')),
                  );
                }
              }
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  void _toggleReminder() async {
    final s = widget.scholarship;
    final notifService = widget.repository.notificationService;
    final isAlreadyScheduled = notifService.hasActiveReminder(s.id);

    if (isAlreadyScheduled) {
      await notifService.cancelReminderForEntity(s.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deadline reminder removed.')),
        );
      }
    } else {
      DateTime targetDate;
      if (s.applicationDeadline != null) {
        try {
          targetDate = DateTime.parse(s.applicationDeadline!);
        } catch (_) {
          targetDate = DateTime.now().add(const Duration(days: 30));
        }
      } else {
        targetDate = DateTime.now().add(const Duration(days: 30));
      }

      final success = await notifService.scheduleReminder(
        id: 'rem-${s.id}',
        title: 'Scholarship Deadline Approaching: ${s.name}',
        body: 'Application deadline is in 7 days. Ensure official documents are prepared.',
        targetDeadline: targetDate,
        entityId: s.id,
        entityType: 'scholarship',
      );

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Reminder scheduled for ${s.name}!'
                  : 'Reminders are disabled in Settings.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scholarship;
    final inst = widget.repository.getInstitutionById(s.institutionId);
    final isShortlisted = widget.repository.isScholarshipShortlisted(s.id);
    final hasReminder = widget.repository.notificationService.hasActiveReminder(s.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship Details'),
        actions: [
          IconButton(
            icon: Icon(
              isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isShortlisted ? AppColors.secondary : null,
            ),
            onPressed: () {
              widget.repository.toggleScholarshipShortlist(s.id);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'Report Data Discrepancy',
            onPressed: _openDiscrepancyDialog,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.providerName ?? inst?.name ?? 'Official Partner',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          if (inst != null && s.providerName != null) ...[
                            Text(
                              'Tenured at: ${inst.name}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(s.scholarshipType, AppColors.primaryContainer, Colors.white),
                    _chip(s.coverageType.name.replaceAll('_', ' ').toUpperCase(), AppColors.secondaryContainer, AppColors.secondary),
                    if (s.country != null) _chip(s.country!, AppColors.surfaceVariant, AppColors.textPrimary),
                    if (s.deadlineStatus == ScholarshipDeadlineStatus.closing)
                      _chip('CLOSING SOON', AppColors.tertiaryContainer, Colors.orange.shade900),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stale Warning Banner if applicable
          if (s.isStale) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_toggle_off_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Information last checked over 6 months ago. Always verify current term criteria on official university portals.',
                      style: TextStyle(fontSize: 11.5, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Coverage & Award Details
          _sectionCard(
            title: 'Coverage & Financial Award',
            icon: Icons.payments_outlined,
            children: [
              Text(
                s.coverageDetails,
                style: const TextStyle(fontSize: 13.5, height: 1.45, color: AppColors.textPrimary),
              ),
              if (s.awardAmount != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Maximum Annual Value: ${s.currency ?? "PKR"} ${s.awardAmount!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Eligibility Criteria
          _sectionCard(
            title: 'Eligibility Requirements',
            icon: Icons.checklist_rounded,
            children: [
              if (s.minPercentage != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.verifiedBadge),
                      const SizedBox(width: 8),
                      Text(
                        'Minimum Academic Score: >= ${s.minPercentage!.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              if (s.eligibilityCriteria.isNotEmpty) ...[
                ...s.eligibilityCriteria.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Expanded(
                            child: Text(c, style: const TextStyle(fontSize: 12.5, height: 1.35)),
                          ),
                        ],
                      ),
                    )),
              ] else ...[
                Text(
                  s.minimumCriteria,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
              if (s.degreeLevels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Applicable Degree Levels: ${s.degreeLevels.join(", ")}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Application Deadline & Reminder Card
          _sectionCard(
            title: 'Application Timeline & Deadlines',
            icon: Icons.calendar_today_rounded,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Application Deadline:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        s.applicationDeadline ?? 'Rolling / Not Published',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _toggleReminder,
                    icon: Icon(
                      hasReminder ? Icons.notifications_active : Icons.notification_add_outlined,
                      size: 16,
                      color: hasReminder ? AppColors.secondary : null,
                    ),
                    label: Text(hasReminder ? 'Reminder Active' : 'Remind Me'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Official Links & Verification Provenance
          _sectionCard(
            title: 'Source Attribution & Official Portals',
            icon: Icons.verified_user_outlined,
            children: [
              if (s.lastCheckedAt != null) ...[
                Text(
                  'Record Last Verified: ${s.lastCheckedAt}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
              ],
              if (s.officialApplicationUrl != null && s.officialApplicationUrl!.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _launchUrl(s.officialApplicationUrl!),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Apply on Official Scholarship Portal'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (s.sourceUrl != null && s.sourceUrl!.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(s.sourceUrl!),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('View Official Criteria Document'),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const Divider(height: 18),
          ...children,
        ],
      ),
    );
  }
}

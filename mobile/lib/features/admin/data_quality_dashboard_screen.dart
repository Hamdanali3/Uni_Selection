// Phase 2 — P2-11 Data Quality & Governance Dashboard Screen
// Visualizes system coverage, verification velocity, data freshness,
// sync engine health, and pending editorial queue metrics.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import 'admin_review_screen.dart';

class DataQualityDashboardScreen extends StatelessWidget {
  final UniSelectionRepository repository;

  const DataQualityDashboardScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final summary = repository.getVerificationSummary();
    final syncRuns = repository.syncRuns;
    final latestRun = syncRuns.isNotEmpty ? syncRuns.last : null;
    final pendingQueueCount = repository.reviewQueue.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Quality & Governance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            tooltip: 'Editorial Review Queue',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminReviewScreen(repository: repository),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Executive Summary Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Catalogue Health Metric',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${summary['verificationRate']}% VERIFIED',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary['totalInstitutions']} Higher Education Institutions',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary['publishedInstitutions']} Published • ${summary['inReviewInstitutions']} In Review • ${summary['draftInstitutions']} Draft',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Key Governance Grid
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: 'National Scope',
                  value: '${summary['nationalInstitutions']}',
                  subtitle: 'HEC Recognized',
                  color: AppColors.primary,
                  icon: Icons.flag_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  title: 'International',
                  value: '${summary['internationalInstitutions']}',
                  subtitle: 'Global Benchmarks',
                  color: AppColors.secondary,
                  icon: Icons.public_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: 'Data Freshness',
                  value: '${summary['staleInstitutions']}',
                  subtitle: 'Stale (> 180 days)',
                  color: (summary['staleInstitutions'] as int) > 0 ? Colors.orange.shade800 : AppColors.verifiedBadge,
                  icon: Icons.history_toggle_off_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  title: 'Editorial Queue',
                  value: '$pendingQueueCount',
                  subtitle: 'Pending Changes',
                  color: pendingQueueCount > 0 ? Colors.amber.shade900 : AppColors.verifiedBadge,
                  icon: Icons.queue_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Detailed Entities Breakdown
          const Text(
            'Entity Coverage Breakdown',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _entityRow('Degree Programmes', '${summary['totalProgrammes']}', Icons.school_outlined),
                const Divider(height: 16),
                _entityRow('Eligibility Rules', '${summary['totalEligibilityRules']}', Icons.gavel_outlined),
                const Divider(height: 16),
                _entityRow('Admission Cycles', '${summary['totalAdmissionCycles']}', Icons.calendar_month_outlined),
                const Divider(height: 16),
                _entityRow('Published Fee Records', '${summary['totalFeeRecords']}', Icons.payments_outlined),
                const Divider(height: 16),
                _entityRow('Scholarships & Aid', '${summary['totalScholarships']}', Icons.stars_outlined),
                const Divider(height: 16),
                _entityRow('Country Guidance Profiles', '${summary['totalCountryGuidance']}', Icons.language_outlined),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sync Engine Health
          const Text(
            'Automated Sync Engine Diagnostics',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sync Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('IDEMPOTENT & ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  latestRun != null
                      ? 'Last Synchronization: ${latestRun['timestamp']} (${latestRun['source']})'
                      : 'Sync Engine: Ready for scheduled execution via GitHub Actions.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminReviewScreen(repository: repository),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: const Text('Open Editorial Console & Review Queue'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _entityRow(String label, String count, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(count, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }
}

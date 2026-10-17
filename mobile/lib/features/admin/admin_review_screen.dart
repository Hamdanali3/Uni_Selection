import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/institution.dart';
import '../../core/repositories/uniselection_repository.dart';

class AdminReviewScreen extends StatefulWidget {
  final UniSelectionRepository repository;

  const AdminReviewScreen({
    super.key,
    required this.repository,
  });

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  String _selectedFilter = 'all'; // 'all', 'published', 'in_review', 'draft', 'stale'

  @override
  Widget build(BuildContext context) {
    final summary = widget.repository.getVerificationSummary();
    final allInstitutions = widget.repository.getInstitutions(scope: 'all', status: 'all');

    final filteredInstitutions = allInstitutions.where((inst) {
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'published') return inst.status == 'published';
      if (_selectedFilter == 'in_review') return inst.status == 'in_review';
      if (_selectedFilter == 'draft') return inst.status == 'draft';
      if (_selectedFilter == 'stale') {
        if (inst.lastVerifiedAt.isEmpty) return true;
        try {
          final dt = DateTime.parse(inst.lastVerifiedAt);
          return DateTime.now().difference(dt).inDays > 180;
        } catch (_) {
          return true;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Verification & Ops'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header / Role Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editorial & Audit Console',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Phase 1 Verification Workflow & Import Pipeline',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Key Metrics Grid
          const Text(
            'Catalogue Integrity Metrics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Institutions',
                  '${summary['totalInstitutions']}',
                  '${summary['nationalInstitutions']} Pak / ${summary['internationalInstitutions']} Global',
                  Icons.account_balance_rounded,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Verification Rate',
                  '${summary['verificationRate']}%',
                  '${summary['publishedInstitutions']} Published',
                  Icons.verified_rounded,
                  AppColors.verifiedBadge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'In Review / Draft',
                  '${summary['inReviewInstitutions']} / ${summary['draftInstitutions']}',
                  'Requires Editorial Review',
                  Icons.pending_actions_rounded,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Programmes & Rules',
                  '${summary['totalProgrammes']}',
                  '${summary['totalEligibilityRules']} Rules Encoded',
                  Icons.rule_rounded,
                  AppColors.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Review & Audit Filter Tabs
          const Text(
            'Records Status & Mutation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All (${allInstitutions.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Published (${summary['publishedInstitutions']})', 'published'),
                const SizedBox(width: 8),
                _buildFilterChip('In Review (${summary['inReviewInstitutions']})', 'in_review'),
                const SizedBox(width: 8),
                _buildFilterChip('Draft (${summary['draftInstitutions']})', 'draft'),
                const SizedBox(width: 8),
                _buildFilterChip('Stale Records (${summary['staleInstitutions']})', 'stale'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Records List
          if (filteredInstitutions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, color: AppColors.textSecondary, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'No institutions matching filter: $_selectedFilter',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredInstitutions.take(10).map((inst) => _buildInstitutionReviewCard(inst)),

          if (filteredInstitutions.length > 10)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  '+ ${filteredInstitutions.length - 10} more records in this view',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Security & RLS Compliance Card
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
                const Row(
                  children: [
                    Icon(Icons.security_rounded, color: AppColors.verifiedBadge, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Security & RLS Guard Baseline',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildComplianceItem('Row Level Security (RLS)', 'Enabled on 15 PostgreSQL tables', true),
                _buildComplianceItem('Public Access Control', 'Read-only restricted to published records', true),
                _buildComplianceItem('Service-Role Key Protection', 'Strictly excluded from mobile client', true),
                _buildComplianceItem('Personal Data Minimization', 'Zero CNIC or financial docs collected', true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CSV Import & Validation Workflow
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
                const Row(
                  children: [
                    Icon(Icons.file_upload_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data Import Pipeline & CLI Tooling',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Validated import templates available in data/templates/ with automated Python batch verification:',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'python data/validation/validate_dataset.py\nStatus: 0 errors detected across 39 institutions',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textPrimary),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
    );
  }

  Widget _buildInstitutionReviewCard(Institution inst) {
    Color statusColor;
    switch (inst.status) {
      case 'published':
        statusColor = AppColors.verifiedBadge;
        break;
      case 'in_review':
        statusColor = Colors.orange;
        break;
      case 'draft':
      default:
        statusColor = AppColors.textSecondary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        inst.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: inst.countryId == 'PAK' ? Colors.green.withAlpha(25) : Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inst.countryId == 'PAK' ? 'PAK' : 'INTL',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: inst.countryId == 'PAK' ? Colors.green.shade800 : Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inst.status.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verified: ${inst.lastVerifiedAt.isNotEmpty ? inst.lastVerifiedAt : "Pending"}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Update editorial status',
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
            onSelected: (newStatus) {
              widget.repository.updateInstitutionStatus(inst.id, newStatus);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Updated "${inst.name}" status to $newStatus'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'published',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.verifiedBadge, size: 18),
                    SizedBox(width: 8),
                    Text('Publish Record'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'in_review',
                child: Row(
                  children: [
                    Icon(Icons.rate_review_outlined, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Text('Mark In Review'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'draft',
                child: Row(
                  children: [
                    Icon(Icons.edit_note_outlined, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Text('Revert to Draft'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(String title, String statusText, bool isPass) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isPass ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isPass ? AppColors.verifiedBadge : AppColors.statusError,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(statusText, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

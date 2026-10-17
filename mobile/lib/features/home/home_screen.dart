import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/institution.dart';
import '../institutions/institution_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final UniSelectionRepository repository;
  final Function(int) onNavigateTab;
  final Function(String categoryId) onSelectCategory;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.onNavigateTab,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isNational = repository.activeScope == 'national';
    final institutions = repository.getInstitutions();
    final categories = repository.categories;
    final admissions = repository.admissions;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'UniSelection',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // National vs International Toggle Pill
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildScopeButton('Pakistan', isNational, () {
                  repository.setScope('national');
                }),
                _buildScopeButton('International', !isNational, () {
                  repository.setScope('international');
                }),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await repository.refresh();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Hero Discovery Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isNational ? 'HEC ACCREDITED DIRECTORY' : 'GLOBAL STARTER CATALOGUE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.verified, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '100% Verified Sources',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isNational
                        ? 'Find Your Future in Pakistan Higher Education'
                        : 'Explore Leading International Universities',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isNational
                        ? 'Search verified programmes, HEC recognized campuses, fee schedules, and transparent eligibility.'
                        : 'Verified starter records for accredited global institutions with official links and admission guidance.',
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick Search / Explore Action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => onNavigateTab(1), // Go to Institutions tab
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text(
                      'Browse All Institutions',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Shortcut Row: Eligibility & Comparison
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.rule_folder_rounded,
                    title: 'Eligibility Guidance',
                    subtitle: 'Check against published criteria',
                    color: AppColors.secondary,
                    onTap: () => onNavigateTab(2), // Eligibility tab
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.compare_arrows_rounded,
                    title: 'Compare Options',
                    subtitle: 'Side-by-side analysis',
                    color: AppColors.tertiary,
                    onTap: () => onNavigateTab(3), // Shortlist tab
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Academic Disciplines / Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Explore by Category',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1),
                  child: const Text('View All', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _buildCategoryChip(cat.name, cat.slug, () {
                    onSelectCategory(cat.id);
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Upcoming / Active Admission Cycles Notice
            if (admissions.isNotEmpty) ...[
              const Text(
                'Admission Deadlines & Schedules',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...admissions.take(2).map((adm) {
                final inst = repository.getInstitutionById(adm.institutionId);
                return _buildAdmissionCard(adm.sessionName, inst?.name ?? '', adm.admissionStatus, adm.closingDate);
              }),
              const SizedBox(height: 24),
            ],

            // Featured Institutions List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isNational ? 'Featured Pakistani Institutions' : 'Curated International Universities',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${institutions.length} available',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...institutions.take(6).map((inst) {
              return _buildInstitutionCard(context, inst);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, String slug, VoidCallback onTap) {
    IconData icon;
    if (slug.contains('eng')) {
      icon = Icons.engineering_rounded;
    } else if (slug.contains('comp')) {
      icon = Icons.computer_rounded;
    } else if (slug.contains('med')) {
      icon = Icons.local_hospital_rounded;
    } else if (slug.contains('biz')) {
      icon = Icons.business_center_rounded;
    } else if (slug.contains('sci')) {
      icon = Icons.science_rounded;
    } else {
      icon = Icons.menu_book_rounded;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionCard(String session, String uniName, String status, String? deadline) {
    Color statusColor;
    if (status == 'Open') {
      statusColor = AppColors.statusOpen;
    } else if (status == 'Upcoming') {
      statusColor = AppColors.statusUpcoming;
    } else {
      statusColor = AppColors.statusClosed;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  uniName,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (deadline != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Deadline', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(
                  deadline,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstitutionCard(BuildContext context, Institution inst) {
    final city = repository.getCity(inst.cityId);
    final isShortlisted = repository.isInstitutionShortlisted(inst.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InstitutionDetailScreen(
                institution: inst,
                repository: repository,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            inst.shortName?.substring(0, 1) ?? inst.name.substring(0, 1),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                inst.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (inst.hecRecognized) ...[
              const Icon(Icons.verified, color: AppColors.verifiedBadge, size: 16),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                city?.name ?? inst.countryId,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inst.institutionType,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            color: isShortlisted ? AppColors.secondary : AppColors.textSecondary,
          ),
          onPressed: () {
            repository.toggleInstitutionShortlist(inst.id);
          },
        ),
      ),
    );
  }
}

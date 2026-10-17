import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/institution.dart';
import '../../core/models/recommendation_result.dart';
import '../institutions/institution_detail_screen.dart';
import '../scholarships/scholarship_finder_screen.dart';
import '../planner/application_planner_screen.dart';
import '../calendar/admissions_calendar_screen.dart';
import '../international/country_guidance_screen.dart';

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

  void _showRecommendationBreakdown(BuildContext context, RecommendationResult rec) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rec.institutionName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${rec.totalScore.toStringAsFixed(0)}% MATCH',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Deterministic Score Breakdown (No Generative Black-Box AI)',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 20),
            ...rec.factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(f.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(
                            '${f.score.toStringAsFixed(0)} / ${f.maxScore.toStringAsFixed(0)} pts',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(f.explanation, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  final inst = repository.getInstitutionById(rec.institutionId);
                  if (inst != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InstitutionDetailScreen(
                          institution: inst,
                          repository: repository,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('View University Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNational = repository.activeScope == 'national';
    final institutions = repository.getInstitutions();
    final categories = repository.categories;
    final admissions = repository.admissions;
    final recommendations = repository.getPersonalizedRecommendations();

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
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => onNavigateTab(1),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text(
                      'Browse All Institutions',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Phase 2 Strategic Feature Hub
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.stars_rounded,
                    title: 'Scholarships & Aid',
                    subtitle: 'Find verified funding',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScholarshipFinderScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.checklist_rtl_rounded,
                    title: 'Application Tracker',
                    subtitle: 'Milestones & checklists',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplicationPlannerScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Admissions Calendar',
                    subtitle: 'Upcoming deadlines',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdmissionsCalendarScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.public_rounded,
                    title: 'Country Guidance',
                    subtitle: 'Visas & global intakes',
                    color: AppColors.tertiary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CountryGuidanceScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // P2-03 Personalized Recommendations Section
            if (recommendations.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Transparent Matching',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...recommendations.take(3).map((rec) {
                final inst = repository.getInstitutionById(rec.institutionId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer.withAlpha(40),
                      child: Text(
                        inst?.shortName?.substring(0, 1) ?? rec.institutionName.substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      rec.institutionName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withAlpha(50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rec.matchLabel.toUpperCase(),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.secondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${rec.totalScore.toStringAsFixed(0)}% Score',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                    trailing: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textSecondary),
                    onTap: () => _showRecommendationBreakdown(context, rec),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

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
                return _buildAdmissionCard(adm.sessionName, inst?.name ?? '', adm.admissionStatus, adm.closingDate ?? 'Rolling');
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
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, String slug, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getCategoryIcon(slug), color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmissionCard(String session, String instName, String status, String deadline) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.alarm, color: AppColors.secondary, size: 20),
        ),
        title: Text(
          session,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$instName • $status • Deadline: $deadline',
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildInstitutionCard(BuildContext context, Institution inst) {
    final city = repository.getCity(inst.cityId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            inst.shortName?.substring(0, 1) ?? inst.name.substring(0, 1),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          inst.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${city?.name ?? inst.countryId} • ${inst.institutionType}',
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
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
      ),
    );
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'engineering':
      case 'eng':
        return Icons.precision_manufacturing_rounded;
      case 'medical':
      case 'med':
        return Icons.medical_services_rounded;
      case 'computer-science':
      case 'cs':
      case 'it':
        return Icons.computer_rounded;
      case 'business':
      case 'bba':
        return Icons.trending_up_rounded;
      case 'general':
      default:
        return Icons.menu_book_rounded;
    }
  }
}

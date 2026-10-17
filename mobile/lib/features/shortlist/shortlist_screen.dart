import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../institutions/institution_detail_screen.dart';
import '../comparison/comparison_screen.dart';
import '../programmes/programme_detail_screen.dart';
import '../scholarships/scholarship_detail_screen.dart';

class ShortlistScreen extends StatefulWidget {
  final UniSelectionRepository repository;
  final Function(int)? onNavigateTab;

  const ShortlistScreen({
    super.key,
    required this.repository,
    this.onNavigateTab,
  });

  @override
  State<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends State<ShortlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedInstitutions = widget.repository.getShortlistedInstitutions();
    final savedProgrammes = widget.repository.getShortlistedProgrammes();
    final savedScholarships = widget.repository.getShortlistedScholarships();

    final hasAny = savedInstitutions.isNotEmpty ||
        savedProgrammes.isNotEmpty ||
        savedScholarships.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Shortlist'),
        actions: [
          if (hasAny) ...[
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Shortlist?'),
                    content: const Text('Are you sure you want to remove all saved universities, programmes, and scholarships?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          await widget.repository.clearShortlist();
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) setState(() {});
                        },
                        child: const Text('Clear All', style: TextStyle(color: AppColors.statusError)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear All', style: TextStyle(color: AppColors.statusError, fontSize: 13)),
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Institutions (${savedInstitutions.length})'),
            Tab(text: 'Programmes (${savedProgrammes.length})'),
            Tab(text: 'Scholarships (${savedScholarships.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Institutions Tab
          savedInstitutions.isEmpty
              ? _buildEmptyState(
                  'No Saved Institutions',
                  'Tap the bookmark icon on any university card to save it here.',
                )
              : Column(
                  children: [
                    if (savedInstitutions.length >= 2) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ComparisonScreen(
                                    repository: widget.repository,
                                    institutions: savedInstitutions,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.compare_arrows_rounded,
                                size: 20),
                            label: Text(
                                'Compare All ${savedInstitutions.length} Saved Universities'),
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: savedInstitutions.length,
                        itemBuilder: (context, index) {
                          final inst = savedInstitutions[index];
                          final city = widget.repository.getCity(inst.cityId);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InstitutionDetailScreen(
                                      institution: inst,
                                      repository: widget.repository,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Text(
                                  inst.shortName?.substring(0, 1) ??
                                      inst.name.substring(0, 1),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              title: Text(
                                inst.name,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${city?.name ?? inst.countryId} • ${inst.institutionType}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.statusError),
                                onPressed: () {
                                  widget.repository
                                      .toggleInstitutionShortlist(inst.id);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

          // 2. Programmes Tab
          savedProgrammes.isEmpty
              ? _buildEmptyState(
                  'No Saved Programmes',
                  'Save degree programmes from any university detail page.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedProgrammes.length,
                  itemBuilder: (context, index) {
                    final prog = savedProgrammes[index];
                    final inst = widget.repository
                        .getInstitutionById(prog.institutionId);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        onTap: () {
                          if (inst != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProgrammeDetailScreen(
                                  programme: prog,
                                  institution: inst,
                                  repository: widget.repository,
                                ),
                              ),
                            );
                          }
                        },
                        title: Text(
                          prog.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              inst?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${prog.degreeLevel} • ${prog.durationYears.toStringAsFixed(0)} Years',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.statusError),
                          onPressed: () {
                            widget.repository
                                .toggleProgrammeShortlist(prog.id);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),

          // 3. Scholarships Tab (Phase 2 P2-07)
          savedScholarships.isEmpty
              ? _buildEmptyState(
                  'No Saved Scholarships',
                  'Bookmark scholarships and financial aid opportunities to track them here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedScholarships.length,
                  itemBuilder: (context, index) {
                    final s = savedScholarships[index];
                    final inst = widget.repository.getInstitutionById(s.institutionId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScholarshipDetailScreen(
                                scholarship: s,
                                repository: widget.repository,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        leading: CircleAvatar(
                          backgroundColor: AppColors.secondaryContainer.withAlpha(50),
                          child: const Icon(Icons.stars_rounded, color: AppColors.secondary),
                        ),
                        title: Text(
                          s.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              s.providerName ?? inst?.name ?? '',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.coverageDetails,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.statusError),
                          onPressed: () {
                            widget.repository.toggleScholarshipShortlist(s.id);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onNavigateTab?.call(1),
              child: const Text('Browse Directory'),
            ),
          ],
        ),
      ),
    );
  }
}

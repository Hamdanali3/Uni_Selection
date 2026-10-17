import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../institutions/institution_detail_screen.dart';
import '../comparison/comparison_screen.dart';

class ShortlistScreen extends StatefulWidget {
  final UniSelectionRepository repository;
  final Function(int) onNavigateTab;

  const ShortlistScreen({
    super.key,
    required this.repository,
    required this.onNavigateTab,
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
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Shortlist'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Institutions (${savedInstitutions.length})'),
            Tab(text: 'Programmes (${savedProgrammes.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Institutions Tab
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

          // Programmes Tab
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
              onPressed: () => widget.onNavigateTab(1),
              child: const Text('Browse Directory'),
            ),
          ],
        ),
      ),
    );
  }
}

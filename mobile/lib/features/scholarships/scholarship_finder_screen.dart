// Phase 2 — P2-01 Scholarship & Financial Aid Finder Screen
// Provides comprehensive search, multi-axis filtering, verified badges,
// deadline status indicators, and shortlist bookmarking for scholarships.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/scholarship.dart';
import '../../core/repositories/uniselection_repository.dart';
import 'scholarship_detail_screen.dart';

class ScholarshipFinderScreen extends StatefulWidget {
  final UniSelectionRepository repository;

  const ScholarshipFinderScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ScholarshipFinderScreen> createState() => _ScholarshipFinderScreenState();
}

class _ScholarshipFinderScreenState extends State<ScholarshipFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ScholarshipFundingType? _selectedFundingType;
  ScholarshipCoverageType? _selectedCoverageType;
  String? _selectedDegreeLevel;
  String? _selectedCountry;
  bool _hideClosed = false;
  bool _hideStale = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedFundingType = null;
      _selectedCoverageType = null;
      _selectedDegreeLevel = null;
      _selectedCountry = null;
      _hideClosed = false;
      _hideStale = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scholarships = widget.repository.getScholarships(
      query: _searchQuery,
      fundingType: _selectedFundingType,
      coverageType: _selectedCoverageType,
      degreeLevel: _selectedDegreeLevel,
      country: _selectedCountry,
      hideClosed: _hideClosed,
      hideStale: _hideStale,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarships & Aid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off_rounded),
            tooltip: 'Reset Filters',
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search scholarships, providers, or universities...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 10),
                // Horizontal filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Funding Filter
                      DropdownButton<ScholarshipFundingType?>(
                        value: _selectedFundingType,
                        hint: const Text('Funding: All', style: TextStyle(fontSize: 12)),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Funding Types', style: TextStyle(fontSize: 12))),
                          ...ScholarshipFundingType.values.map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedFundingType = val),
                      ),
                      const SizedBox(width: 8),
                      // Coverage Filter
                      DropdownButton<ScholarshipCoverageType?>(
                        value: _selectedCoverageType,
                        hint: const Text('Coverage: All', style: TextStyle(fontSize: 12)),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Coverage', style: TextStyle(fontSize: 12))),
                          ...ScholarshipCoverageType.values.map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedCoverageType = val),
                      ),
                      const SizedBox(width: 8),
                      // Degree Level Filter
                      DropdownButton<String?>(
                        value: _selectedDegreeLevel,
                        hint: const Text('Level: All', style: TextStyle(fontSize: 12)),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Levels', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'undergraduate', child: Text('Undergraduate', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'masters', child: Text('Masters', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'doctorate', child: Text('Doctorate / PhD', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) => setState(() => _selectedDegreeLevel = val),
                      ),
                      const SizedBox(width: 8),
                      // Hide Closed Toggle
                      FilterChip(
                        selected: _hideClosed,
                        label: const Text('Open Only', style: TextStyle(fontSize: 11)),
                        onSelected: (val) => setState(() => _hideClosed = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Count & Guidance banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceVariant.withAlpha(80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${scholarships.length} Verified Scholarship(s) Found',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: AppColors.verifiedBadge),
                    SizedBox(width: 4),
                    Text('100% Sourced', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.verifiedBadge)),
                  ],
                ),
              ],
            ),
          ),

          // List of Scholarships
          Expanded(
            child: scholarships.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: scholarships.length,
                    itemBuilder: (context, index) {
                      final s = scholarships[index];
                      final inst = widget.repository.getInstitutionById(s.institutionId);
                      final isShortlisted = widget.repository.isScholarshipShortlisted(s.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            s.providerName ?? inst?.shortName ?? inst?.name ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                        color: isShortlisted ? AppColors.secondary : AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        widget.repository.toggleScholarshipShortlist(s.id);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.coverageDetails,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _badge(s.scholarshipType, AppColors.primaryContainer, Colors.white),
                                    _badge(s.coverageType.name.replaceAll('_', ' ').toUpperCase(), AppColors.secondaryContainer, AppColors.secondary),
                                    if (s.applicationDeadline != null)
                                      _badge('Deadline: ${s.applicationDeadline}', AppColors.surfaceVariant, AppColors.textPrimary),
                                    if (s.isStale)
                                      _badge('Needs Re-check', Colors.amber.shade100, Colors.amber.shade900),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(Icons.school_outlined, size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scholarships Match Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try relaxing your funding or coverage filters to view available financial aid options.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetFilters,
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

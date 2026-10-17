import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/institution.dart';
import 'institution_detail_screen.dart';

class InstitutionsScreen extends StatefulWidget {
  final UniSelectionRepository repository;
  final String? initialCategoryId;

  const InstitutionsScreen({
    super.key,
    required this.repository,
    this.initialCategoryId,
  });

  @override
  State<InstitutionsScreen> createState() => _InstitutionsScreenState();
}

class _InstitutionsScreenState extends State<InstitutionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCityId;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedCityId = null;
      _selectedType = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNational = widget.repository.activeScope == 'national';
    final categories = widget.repository.categories;
    final cities = widget.repository.cities.where((c) {
      if (isNational) return c.countryId == 'PAK';
      return c.countryId != 'PAK';
    }).toList();

    final institutions = widget.repository.getInstitutions(
      categoryId: _selectedCategoryId,
      cityId: _selectedCityId,
      institutionType: _selectedType,
      query: _searchController.text,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isNational ? 'Pakistan Universities' : 'International Institutions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterBottomSheet(context, categories, cities),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by university name, acronym, or city...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Active Filter Chips Row
          if (_selectedCategoryId != null || _selectedCityId != null || _selectedType != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_selectedCategoryId != null) ...[
                      Chip(
                        label: Text(
                          widget.repository.getCategory(_selectedCategoryId!)?.name ?? 'Category',
                          style: const TextStyle(fontSize: 11),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _selectedCategoryId = null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_selectedCityId != null) ...[
                      Chip(
                        label: Text(
                          widget.repository.getCity(_selectedCityId)?.name ?? 'City',
                          style: const TextStyle(fontSize: 11),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _selectedCityId = null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_selectedType != null) ...[
                      Chip(
                        label: Text(_selectedType!, style: const TextStyle(fontSize: 11)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _selectedType = null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset All', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Results Count Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                Text(
                  '${institutions.length} institutions found',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isNational) ...[
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.verifiedBadge),
                  const SizedBox(width: 4),
                  const Text(
                    'HEC Recognized',
                    style: TextStyle(fontSize: 11, color: AppColors.verifiedBadge, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),

          // Institution Cards List or Empty State
          Expanded(
            child: institutions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: institutions.length,
                    itemBuilder: (context, index) {
                      final inst = institutions[index];
                      return _buildInstitutionItem(context, inst);
                    },
                  ),
          ),
        ],
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
              child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Institutions Match Filters',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try clearing your search query or removing category/city filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

  Widget _buildInstitutionItem(BuildContext context, Institution inst) {
    final city = widget.repository.getCity(inst.cityId);
    final campuses = widget.repository.getCampusesForInstitution(inst.id);
    final programmes = widget.repository.getProgrammesForInstitution(inst.id);
    final isShortlisted = widget.repository.isInstitutionShortlisted(inst.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      inst.shortName?.substring(0, 1) ?? inst.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inst.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (inst.shortName != null) ...[
                          Text(
                            inst.shortName!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: isShortlisted ? AppColors.secondary : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      widget.repository.toggleInstitutionShortlist(inst.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Sector & Location Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inst.institutionType,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 2),
                  Text(
                    city?.name ?? inst.countryId,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  if (inst.hecRecognized) ...[
                    const Icon(Icons.verified, color: AppColors.verifiedBadge, size: 15),
                    const SizedBox(width: 3),
                    const Text(
                      'Verified',
                      style: TextStyle(fontSize: 11, color: AppColors.verifiedBadge, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
              const Divider(height: 20, color: AppColors.border),
              // Footer Stats: Campuses, Programmes, Last Verified
              Row(
                children: [
                  Text(
                    '${campuses.length} Campuses',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    '${programmes.length} Programmes',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    'Audited: ${inst.lastVerifiedAt}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, List categories, List cities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Institutions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      TextButton(
                        onPressed: () {
                          _resetFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ACADEMIC CATEGORY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: categories.map<Widget>((cat) {
                      final isSelected = _selectedCategoryId == cat.id;
                      return ChoiceChip(
                        label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategoryId = selected ? cat.id : null;
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SECTOR / GOVERNANCE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Public', 'Private', 'Autonomous'].map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedType = selected ? type : null;
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

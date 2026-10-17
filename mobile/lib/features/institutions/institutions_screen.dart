import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/institution.dart';
import '../../core/models/programme.dart';
import 'institution_detail_screen.dart';
import '../programmes/programme_detail_screen.dart';

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

class _InstitutionsScreenState extends State<InstitutionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCityId;
  String? _selectedType;
  String? _selectedDegreeLevel;
  String? _selectedDisciplineId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategoryId = widget.initialCategoryId;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedCityId = null;
      _selectedType = null;
      _selectedDegreeLevel = null;
      _selectedDisciplineId = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNational = widget.repository.activeScope == 'national';
    final categories = widget.repository.categories;
    final disciplines = widget.repository.disciplines;
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

    final programmes = widget.repository.searchProgrammes(
      disciplineId: _selectedDisciplineId,
      degreeLevel: _selectedDegreeLevel,
      query: _searchController.text,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(isNational ? 'Pakistan Universities' : 'International Institutions'),
        actions: [
          // National vs International Toggle Pill in AppBar
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildScopeChip('Pak', isNational, () {
                  widget.repository.setScope('national');
                  setState(() {
                    _selectedCityId = null;
                  });
                }),
                _buildScopeChip('Global', !isNational, () {
                  widget.repository.setScope('international');
                  setState(() {
                    _selectedCityId = null;
                  });
                }),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filter Catalogue',
            onPressed: () => _showFilterBottomSheet(context, categories, cities, disciplines),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Universities (${institutions.length})'),
            Tab(text: 'Programmes (${programmes.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // International limited coverage banner (as required by test plan pass criteria)
          if (!isNational) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.secondaryContainer,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF0F766E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Curated Starter Catalogue: Showing accredited sample global universities. Comprehensive worldwide coverage is not claimed.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF0F766E), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _tabController.index == 0
                    ? 'Search by university name, acronym, city, or discipline...'
                    : 'Search by programme title or offering university...',
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
          if (_selectedCategoryId != null ||
              _selectedCityId != null ||
              _selectedType != null ||
              _selectedDegreeLevel != null ||
              _selectedDisciplineId != null) ...[
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
                    if (_selectedDegreeLevel != null) ...[
                      Chip(
                        label: Text(_selectedDegreeLevel!, style: const TextStyle(fontSize: 11)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _selectedDegreeLevel = null),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_selectedDisciplineId != null) ...[
                      Chip(
                        label: Text(
                          widget.repository.getDiscipline(_selectedDisciplineId!)?.name ?? 'Discipline',
                          style: const TextStyle(fontSize: 11),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _selectedDisciplineId = null),
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

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Universities
                institutions.isEmpty
                    ? _buildEmptyState('No Universities Match Filters', 'Try clearing your search query or removing category/city filters.')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: institutions.length,
                        itemBuilder: (context, index) {
                          final inst = institutions[index];
                          return _buildInstitutionItem(context, inst);
                        },
                      ),

                // Tab 2: Programmes Catalogue
                programmes.isEmpty
                    ? _buildEmptyState('No Programmes Match Filters', 'Try searching a different degree name or clearing degree filters.')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: programmes.length,
                        itemBuilder: (context, index) {
                          final prog = programmes[index];
                          return _buildProgrammeItem(context, prog);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
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
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
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
              child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
    final country = widget.repository.getCountry(inst.countryId);
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
                    '${city?.name ?? ""}${city != null ? ", " : ""}${country?.name ?? inst.countryId}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  if (inst.countryId == 'PAK' && inst.hecRecognized) ...[
                    const Icon(Icons.verified, color: AppColors.verifiedBadge, size: 15),
                    const SizedBox(width: 3),
                    const Text(
                      'HEC Recognized',
                      style: TextStyle(fontSize: 11, color: AppColors.verifiedBadge, fontWeight: FontWeight.w700),
                    ),
                  ] else if (inst.countryId != 'PAK') ...[
                    Text(
                      inst.accreditationBody != null ? inst.accreditationBody! : 'Accredited',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.secondary, fontWeight: FontWeight.w600),
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

  Widget _buildProgrammeItem(BuildContext context, Programme prog) {
    final inst = widget.repository.getInstitutionById(prog.institutionId);
    final discipline = widget.repository.getDiscipline(prog.disciplineId);
    final rule = widget.repository.getEligibilityRuleForProgramme(prog.id);
    final fee = widget.repository.getFeeRecordForProgramme(prog.id);
    final isShortlisted = widget.repository.isProgrammeShortlisted(prog.id);

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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    prog.degreeLevel,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${prog.durationYears.toStringAsFixed(0)} Years • ${discipline?.name ?? ""}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (rule != null && rule.minPercentage != null) ...[
              const SizedBox(height: 4),
              Text(
                'Min Requirement: ${rule.minPercentage!.toStringAsFixed(0)}% aggregate',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F766E), fontWeight: FontWeight.w600),
              ),
            ],
            if (fee != null) ...[
              const SizedBox(height: 2),
              Text(
                'Tuition: ${fee.currency} ${fee.tuitionFee.toStringAsFixed(0)} (${fee.billingBasis})',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            color: isShortlisted ? AppColors.secondary : AppColors.textSecondary,
          ),
          onPressed: () {
            widget.repository.toggleProgrammeShortlist(prog.id);
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, List categories, List cities, List disciplines) {
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
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Catalogue',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. Academic Category
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

                    // 2. City / Geographic Region
                    if (cities.isNotEmpty) ...[
                      const Text(
                        'LOCATION / CITY',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: cities.take(10).map<Widget>((city) {
                          final isSelected = _selectedCityId == city.id;
                          return ChoiceChip(
                            label: Text(city.name, style: const TextStyle(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedCityId = selected ? city.id : null;
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 3. Degree Level
                    const Text(
                      'DEGREE LEVEL',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Undergraduate', 'Postgraduate', 'Doctorate'].map((level) {
                        final isSelected = _selectedDegreeLevel == level;
                        return ChoiceChip(
                          label: Text(level, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedDegreeLevel = selected ? level : null;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 4. Sector / Governance
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
                );
              },
            );
          },
        );
      },
    );
  }
}

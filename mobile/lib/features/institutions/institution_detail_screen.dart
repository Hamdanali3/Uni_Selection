import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/institution.dart';
import '../programmes/programme_detail_screen.dart';

class InstitutionDetailScreen extends StatefulWidget {
  final Institution institution;
  final UniSelectionRepository repository;

  const InstitutionDetailScreen({
    super.key,
    required this.institution,
    required this.repository,
  });

  @override
  State<InstitutionDetailScreen> createState() => _InstitutionDetailScreenState();
}

class _InstitutionDetailScreenState extends State<InstitutionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inst = widget.institution;
    final city = widget.repository.getCity(inst.cityId);
    final country = widget.repository.getCountry(inst.countryId);
    final campuses = widget.repository.getCampusesForInstitution(inst.id);
    final programmes = widget.repository.getProgrammesForInstitution(inst.id);
    final admissions = widget.repository.getAdmissionsForInstitution(inst.id);
    final isShortlisted = widget.repository.isInstitutionShortlisted(inst.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(inst.shortName ?? inst.name),
        actions: [
          IconButton(
            icon: Icon(
              isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isShortlisted ? AppColors.secondary : null,
            ),
            onPressed: () {
              widget.repository.toggleInstitutionShortlist(inst.id);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Open Official Website',
            onPressed: () => _launchUrl(inst.officialWebsite),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        inst.shortName?.substring(0, 1) ?? inst.name.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inst.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                '${city?.name ?? ""}, ${country?.name ?? inst.countryId}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Sector: ${inst.institutionType}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (inst.countryId == 'PAK' && inst.hecRecognized) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 13, color: AppColors.secondary),
                            SizedBox(width: 4),
                            Text(
                              'HEC Recognized',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (inst.countryId != 'PAK') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 13, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              inst.accreditationBody != null
                                  ? 'Accredited: ${inst.accreditationBody!}'
                                  : 'Statutory Accreditation',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Verification & Attribution Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: AppColors.surfaceVariant,
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.verifiedBadge),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Published record audited on ${inst.lastVerifiedAt}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _launchUrl(inst.officialWebsite),
                  child: const Text(
                    'Source Link',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs Header
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                const Tab(text: 'Overview'),
                Tab(text: 'Programmes (${programmes.length})'),
                Tab(text: 'Campuses (${campuses.length})'),
                const Tab(text: 'Admissions'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(inst),
                _buildProgrammesTab(programmes),
                _buildCampusesTab(campuses),
                _buildAdmissionsTab(admissions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Institution inst) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inst.overview != null) ...[
          const Text(
            'About Institution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              inst.overview!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const Text(
          'Official Channels & Links',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: const Text('Official Portal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(inst.officialWebsite, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl(inst.officialWebsite),
              ),
              if (inst.admissionsUrl != null) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.how_to_reg_rounded, color: AppColors.secondary),
                  title: const Text('Admissions Office Portal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(inst.admissionsUrl!, style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchUrl(inst.admissionsUrl!),
                ),
              ],
              if (inst.contactEmail != null) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppColors.tertiary),
                  title: const Text('Official Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(inst.contactEmail!, style: const TextStyle(fontSize: 12)),
                ),
              ],
              if (inst.contactPhone != null) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                  title: const Text('Admissions Helpdesk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(inst.contactPhone!, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Compliance Notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'UniSelection publishes verified data cited from official prospectuses and regulator registries. We do not provide admission guarantees or handle university fees directly.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgrammesTab(List programmes) {
    if (programmes.isEmpty) {
      return const Center(
        child: Text('No programmes currently catalogued for this institution.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programmes.length,
      itemBuilder: (context, index) {
        final prog = programmes[index];
        final rule = widget.repository.getEligibilityRuleForProgramme(prog.id);
        final fee = widget.repository.getFeeRecordForProgramme(prog.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgrammeDetailScreen(
                    programme: prog,
                    institution: widget.institution,
                    repository: widget.repository,
                  ),
                ),
              );
            },
            title: Text(
              prog.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
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
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${prog.durationYears.toStringAsFixed(0)} Years • ${prog.studyMode}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (rule != null && rule.minPercentage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Min Criterion: ${rule.minPercentage!.toStringAsFixed(0)}% aggregate',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                ],
                if (fee != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tuition: ${fee.currency} ${fee.tuitionFee.toStringAsFixed(0)} (${fee.billingBasis})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
        );
      },
    );
  }

  Widget _buildCampusesTab(List campuses) {
    if (campuses.isEmpty) {
      return const Center(
        child: Text('Main campus listed under general directory.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campuses.length,
      itemBuilder: (context, index) {
        final campus = campuses[index];
        final city = widget.repository.getCity(campus.cityId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campus.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (campus.isMainCampus) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MAIN CAMPUS',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    city?.name ?? 'Location Verified',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (campus.hecRecognized) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.verifiedBadge),
                    SizedBox(width: 4),
                    Text(
                      'HEC Recognized Campus',
                      style: TextStyle(fontSize: 11, color: AppColors.verifiedBadge, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdmissionsTab(List admissions) {
    if (admissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text(
                'No Active Deadlines Announced',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Check the official university admissions link for unannounced cycles.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _launchUrl(widget.institution.officialWebsite),
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('Open Admissions Portal'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admissions.length,
      itemBuilder: (context, index) {
        final adm = admissions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      adm.sessionName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: adm.admissionStatus == 'Open'
                          ? AppColors.statusOpen.withAlpha(30)
                          : adm.admissionStatus == 'Upcoming'
                              ? AppColors.statusUpcoming.withAlpha(30)
                              : AppColors.statusClosed.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      adm.admissionStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: adm.admissionStatus == 'Open'
                            ? AppColors.statusOpen
                            : adm.admissionStatus == 'Upcoming'
                                ? AppColors.statusUpcoming
                                : AppColors.statusClosed,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (adm.closingDate != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Application Deadline:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(adm.closingDate!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              if (adm.entryTestDate != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Scheduled Entry Test:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(adm.entryTestDate!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _launchUrl(adm.sourceUrl),
                child: const Text(
                  'Verify on Official Schedule Portal →',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

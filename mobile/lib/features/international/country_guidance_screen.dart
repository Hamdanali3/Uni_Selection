// Phase 2 — P2-12 Bounded International Admissions & Country Guidance Screen
// Authoritative, official-source country profiles for Pakistani students researching overseas study.
// Strictly uses official government visa and education links. No unauthorized agents.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/country_guidance.dart';
import '../../core/repositories/uniselection_repository.dart';

class CountryGuidanceScreen extends StatefulWidget {
  final UniSelectionRepository repository;

  const CountryGuidanceScreen({
    super.key,
    required this.repository,
  });

  @override
  State<CountryGuidanceScreen> createState() => _CountryGuidanceScreenState();
}

class _CountryGuidanceScreenState extends State<CountryGuidanceScreen> {
  String _selectedCountryCode = 'GBR';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guidances = widget.repository.countryGuidances;
    final current = widget.repository.getCountryGuidance(_selectedCountryCode) ??
        (guidances.isNotEmpty ? guidances.first : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Country Guidance'),
      ),
      body: guidances.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public_off_rounded, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text('Country Guidance Loading', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Official immigration rules and visa links are loading from the verified dataset.',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Prominent Legal Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.gavel_rounded, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          CountryGuidance.disclaimer,
                          style: TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Country Selector Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: guidances.any((g) => g.countryCode == _selectedCountryCode)
                          ? _selectedCountryCode
                          : guidances.first.countryCode,
                      items: guidances.map((g) {
                        return DropdownMenuItem(
                          value: g.countryCode,
                          child: Row(
                            children: [
                              Text(g.flagEmoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Text(
                                '${g.countryName} (${g.countryCode})',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCountryCode = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (current != null) ...[
                  // Country Overview Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(current.flagEmoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    current.countryName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Code: ${current.countryCode} • Approved Destination',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(
                          current.overviewText,
                          style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Academic Year & Timeline
                  _section(
                    title: 'Academic Year & Intakes',
                    icon: Icons.date_range_rounded,
                    children: [
                      _row('Standard Academic Year:', current.academicYear ?? 'September – June'),
                      const SizedBox(height: 6),
                      _row('Typical Application Windows:', current.applicationWindow ?? 'October – January (Fall Intake)'),
                      if (current.languageOfInstruction != null) ...[
                        const SizedBox(height: 6),
                        _row('Language of Instruction:', current.languageOfInstruction!),
                      ],
                      if (current.languageRequirements != null) ...[
                        const SizedBox(height: 6),
                        _row('Language Proficiency Tests:', current.languageRequirements!),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Student Visa & Official Authority
                  _section(
                    title: 'Student Visa & Immigration Authority',
                    icon: Icons.assignment_ind_outlined,
                    children: [
                      if (current.visaTypeName != null) ...[
                        _row('Official Visa Category:', current.visaTypeName!),
                        const SizedBox(height: 12),
                      ],
                      if (current.visaAuthorityUrl != null && current.visaAuthorityUrl!.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _launchUrl(current.visaAuthorityUrl!),
                            icon: const Icon(Icons.shield_outlined, size: 18),
                            label: const Text('Open Official Visa Authority Portal'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (current.immigrationPortalUrl != null && current.immigrationPortalUrl!.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(current.immigrationPortalUrl!),
                            icon: const Icon(Icons.open_in_browser, size: 18),
                            label: const Text('Government Student Portal'),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Curated Official Links
                  if (current.officialLinks.isNotEmpty) ...[
                    _section(
                      title: 'Official Education & Statutory Links',
                      icon: Icons.link_rounded,
                      children: current.officialLinks.map((link) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(link.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              subtitle: link.description.isNotEmpty ? Text(link.description, style: const TextStyle(fontSize: 11.5)) : null,
                              trailing: const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                              onTap: () => _launchUrl(link.url),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (current.lastReviewedAt != null) ...[
                    Center(
                      child: Text(
                        'Country guidance reviewed on: ${current.lastReviewedAt}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _section({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
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
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const Divider(height: 18),
          ...children,
        ],
      ),
    );
  }
}

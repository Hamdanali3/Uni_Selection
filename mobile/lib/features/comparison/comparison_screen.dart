import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../../core/models/institution.dart';
import '../../core/models/fee_record.dart';

class ComparisonScreen extends StatelessWidget {
  final UniSelectionRepository repository;
  final List<Institution> institutions;

  const ComparisonScreen({
    super.key,
    required this.repository,
    required this.institutions,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (institutions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Institutions')),
        body: const Center(
          child: Text('No institutions selected for comparison.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare (${institutions.length} Institutions)'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
              border: TableBorder.all(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              columnSpacing: 28,
              columns: [
                const DataColumn(
                  label: Text(
                    'ATTRIBUTES',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                ...institutions.map((inst) {
                  return DataColumn(
                    label: Text(
                      inst.shortName ?? inst.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                    ),
                  );
                }),
              ],
              rows: [
                // 1. Full Legal Name
                DataRow(cells: [
                  const DataCell(Text('Full Legal Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) => DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(inst.name, style: const TextStyle(fontSize: 12)),
                        ),
                      )),
                ]),

                // 2. Location (City & Country)
                DataRow(cells: [
                  const DataCell(Text('City & Country', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) {
                    final city = repository.getCity(inst.cityId);
                    final country = repository.getCountry(inst.countryId);
                    return DataCell(
                      Text('${city?.name ?? "Main"}, ${country?.name ?? inst.countryId}', style: const TextStyle(fontSize: 12)),
                    );
                  }),
                ]),

                // 3. Sector / Governance
                DataRow(cells: [
                  const DataCell(Text('Sector', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) => DataCell(
                        Text(inst.institutionType, style: const TextStyle(fontSize: 12)),
                      )),
                ]),

                // 4. Accreditation Status
                DataRow(cells: [
                  const DataCell(Text('Accreditation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) => DataCell(
                        inst.countryId == 'PAK'
                            ? (inst.hecRecognized
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.verifiedBadge, size: 16),
                                      SizedBox(width: 4),
                                      Text('HEC Recognized', style: TextStyle(color: AppColors.verifiedBadge, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  )
                                : const Text('Not listed', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)))
                            : SizedBox(
                                width: 140,
                                child: Text(
                                  inst.accreditationBody ?? 'Statutory Accreditation',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                ),
                              ),
                      )),
                ]),

                // 5. Total Campuses
                DataRow(cells: [
                  const DataCell(Text('Campuses Count', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) {
                    final campuses = repository.getCampusesForInstitution(inst.id);
                    return DataCell(
                      Text('${campuses.isEmpty ? 1 : campuses.length} Campuses', style: const TextStyle(fontSize: 12)),
                    );
                  }),
                ]),

                // 6. Programmes Catalogued
                DataRow(cells: [
                  const DataCell(Text('Catalogued Degrees', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) {
                    final progs = repository.getProgrammesForInstitution(inst.id);
                    return DataCell(
                      Text('${progs.length} Programmes', style: const TextStyle(fontSize: 12)),
                    );
                  }),
                ]),

                // 7. Sample Tuition Basis
                DataRow(cells: [
                  const DataCell(Text('Tuition Fee Basis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) {
                    final progs = repository.getProgrammesForInstitution(inst.id);
                    FeeRecord? sampleFee;
                    for (var p in progs) {
                      final f = repository.getFeeRecordForProgramme(p.id);
                      if (f != null) {
                        sampleFee = f;
                        break;
                      }
                    }
                    if (sampleFee != null) {
                      return DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${sampleFee.currency} ${sampleFee.tuitionFee.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${sampleFee.billingBasis} • ${sampleFee.academicSession}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const DataCell(
                      Text('Check Prospectus', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    );
                  }),
                ]),

                // 8. Official Website
                DataRow(cells: [
                  const DataCell(Text('Official Portal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ...institutions.map((inst) => DataCell(
                        InkWell(
                          onTap: () => _launchUrl(inst.officialWebsite),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Open Website', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 14, color: AppColors.secondary),
                            ],
                          ),
                        ),
                      )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

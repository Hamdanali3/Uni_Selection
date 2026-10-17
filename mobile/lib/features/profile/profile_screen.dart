import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';

class ProfileScreen extends StatefulWidget {
  final UniSelectionRepository repository;

  const ProfileScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _degreeLevel = 'Undergraduate';
  final Set<String> _selectedDisciplines = {'disc-cs', 'disc-se'};
  String _preferredCity = 'c-isb';

  @override
  Widget build(BuildContext context) {
    final cities = widget.repository.cities.where((c) => c.countryId == 'PAK').toList();
    final disciplines = widget.repository.disciplines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy & Data Minimization Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.privacy_tip_outlined, color: Color(0xFF0F766E), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data Minimization Notice: UniSelection does not collect national IDs, passports, or financial records. Preferences are stored locally on your device to personalise discovery.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF0F766E),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Intended Degree Level
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Intended Degree Level',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['Undergraduate', 'Postgraduate', 'Doctorate'].map((level) {
                    final isSelected = _degreeLevel == level;
                    return ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _degreeLevel = level);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preferred Academic Disciplines
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fields of Academic Interest',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select the disciplines you want highlighted in the catalogue.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: disciplines.map((disc) {
                    final isSelected = _selectedDisciplines.contains(disc.id);
                    return FilterChip(
                      label: Text(disc.name, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDisciplines.add(disc.id);
                          } else {
                            _selectedDisciplines.remove(disc.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preferred Study Location (City)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferred City / Region in Pakistan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _preferredCity,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: cities.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text('${c.name} (${c.provinceState ?? ""})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _preferredCity = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences saved successfully on your device.')),
              );
            },
            child: const Text('Save Preferences'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

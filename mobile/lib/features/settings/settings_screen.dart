import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../admin/admin_review_screen.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final UniSelectionRepository repository;

  const SettingsScreen({
    super.key,
    required this.repository,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backendStatusText = repository.remoteApi.isConfigured
        ? (repository.backendStatus == BackendSyncStatus.connected
            ? 'Supabase REST Connected'
            : 'Connecting / Syncing...')
        : 'Offline Starter Dataset (Active)';

    final isOffline = !repository.remoteApi.isConfigured ||
        repository.backendStatus == BackendSyncStatus.offlineFallback;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UniSelection',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Phase 1 MVP • Version 1.0.0 (v1.2 Baseline)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // System Diagnostics & Backend Connectivity
          const Text(
            'System Diagnostics & Data Sync',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
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
                  leading: Icon(
                    isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                    color: isOffline ? AppColors.secondary : AppColors.verifiedBadge,
                  ),
                  title: const Text('Backend Data Channel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(backendStatusText, style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isOffline ? Colors.amber : Colors.green).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOffline ? 'OFFLINE SEED' : 'LIVE API',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isOffline ? Colors.orange.shade900 : Colors.green.shade800,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage_rounded, color: AppColors.tertiary),
                  title: const Text('Local Starter Dataset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('39 institutions • 14 programmes • 100% cited', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.check_circle, color: AppColors.verifiedBadge, size: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Student Preferences & Directory Mode
          const Text(
            'Preferences & Exploration',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
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
                  leading: const Icon(Icons.tune_rounded, color: AppColors.secondary),
                  title: const Text('Student Study Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Degree level, discipline interests, and target cities', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(repository: repository),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.public_rounded, color: AppColors.primary),
                  title: const Text('Current Directory Scope', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    repository.activeScope == 'national'
                        ? 'Pakistan (HEC Recognized Institutions)'
                        : 'Curated International Institutions',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: repository.activeScope == 'national',
                    onChanged: (isNat) {
                      repository.setScope(isNat ? 'national' : 'international');
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded, color: AppColors.statusError),
                  title: const Text('Reset Onboarding Walkthrough', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Allows re-experiencing the National vs Global welcome screen', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    await repository.resetOnboarding();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Onboarding reset. Relaunch the app to view the welcome flow.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Regulatory & Source Information
          const Text(
            'Data Sources & Governance',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
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
                  leading: const Icon(Icons.verified_outlined, color: AppColors.verifiedBadge),
                  title: const Text('HEC Recognized Universities List', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Higher Education Commission Pakistan Official Portal', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchUrl('https://www.hec.gov.pk/english/universities/Pages/recognised.aspx'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_city_outlined, color: AppColors.verifiedBadge),
                  title: const Text('HEC Recognized Campuses List', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Official statutory regional sub-campus registry', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchUrl('https://www.hec.gov.pk/english/universities/Pages/DAIs/HEC-recognized-Campuses.aspx'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.tertiary),
                  title: const Text('Data Verification & Editorial Console', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Integrity stats, RLS compliance, and import status', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminReviewScreen(repository: repository),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Legal & Transparency
          const Text(
            'Legal & Transparency Notices',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Informational Guidance Disclaimer',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'UniSelection is an independent student information platform. All criteria, admission deadlines, and fee schedules are cited from official public sources. UniSelection does not make official admission decisions, guarantee admission, or handle payments.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
                Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Privacy & Data Minimization',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'We do not collect CNIC numbers, passports, bank statements, or academic mark-sheets in Phase 1. Shortlist bookmarks and study preferences are stored strictly on your local device.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

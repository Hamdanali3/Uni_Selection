import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';

class ScopeSelectorScreen extends StatelessWidget {
  final UniSelectionRepository repository;
  final VoidCallback onScopeSelected;

  const ScopeSelectorScreen({
    super.key,
    required this.repository,
    required this.onScopeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App Brand Logo / Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withAlpha(50), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'UniSelection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Transparent, verified admissions & academic programme guidance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              const Text(
                'CHOOSE YOUR PRIMARY DIRECTORY',
                style: TextStyle(
                  color: AppColors.secondaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              // Option 1: National (Pakistan)
              _buildScopeCard(
                context,
                title: 'Pakistan (National)',
                subtitle:
                    'Explore HEC recognized universities, campuses, NET/NAT schedules, and official fee structures.',
                badge: 'HEC RECOGNIZED',
                icon: Icons.flag_rounded,
                isRecommended: true,
                onTap: () async {
                  await repository.setScope('national');
                  onScopeSelected();
                },
              ),
              const SizedBox(height: 14),
              // Option 2: International
              _buildScopeCard(
                context,
                title: 'International Institutions',
                subtitle:
                    'Curated starter directory of renowned universities in UK, USA, Canada, Germany, Australia, and more.',
                badge: 'CURATED STARTER',
                icon: Icons.public_rounded,
                isRecommended: false,
                onTap: () async {
                  await repository.setScope('international');
                  onScopeSelected();
                },
              ),
              const SizedBox(height: 24),
              Text(
                'You can switch between national and international institutions at any time from the app bar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScopeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isRecommended
                ? Border.all(color: AppColors.secondary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRecommended
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isRecommended ? AppColors.secondary : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isRecommended
                                ? AppColors.secondary.withAlpha(30)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isRecommended
                                  ? AppColors.secondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/repositories/uniselection_repository.dart';
import 'theme.dart';
import 'main_shell.dart';
import '../features/onboarding/scope_selector_screen.dart';

class UniSelectionApp extends StatefulWidget {
  final UniSelectionRepository repository;

  const UniSelectionApp({
    super.key,
    required this.repository,
  });

  @override
  State<UniSelectionApp> createState() => _UniSelectionAppState();
}

class _UniSelectionAppState extends State<UniSelectionApp> {
  late Future<void> _initializationFuture;
  bool _hasSelectedScope = false;

  @override
  void initState() {
    super.initState();
    _initializationFuture = widget.repository.initialize().then((_) {
      if (mounted) {
        setState(() {
          _hasSelectedScope = widget.repository.hasCompletedOnboarding;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniSelection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: AppColors.primary,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_rounded, color: Colors.white, size: 54),
                    SizedBox(height: 16),
                    Text(
                      'UniSelection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading verified admissions data...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: AppColors.secondary),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.statusError, size: 48),
                      const SizedBox(height: 14),
                      const Text(
                        'Unable to load starter dataset',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (!widget.repository.hasCompletedOnboarding && !_hasSelectedScope) {
            return ScopeSelectorScreen(
              repository: widget.repository,
              onScopeSelected: () {
                setState(() {
                  _hasSelectedScope = true;
                });
              },
            );
          }

          return MainShell(repository: widget.repository);
        },
      ),
    );
  }
}

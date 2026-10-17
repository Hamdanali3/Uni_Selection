import 'package:flutter/material.dart';
import '../core/repositories/uniselection_repository.dart';
import '../features/home/home_screen.dart';
import '../features/institutions/institutions_screen.dart';
import '../features/eligibility/eligibility_screen.dart';
import '../features/shortlist/shortlist_screen.dart';
import '../features/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  final UniSelectionRepository repository;

  const MainShell({
    super.key,
    required this.repository,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _filterCategoryId;

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
      _filterCategoryId = null;
    });
  }

  void _onSelectCategory(String categoryId) {
    setState(() {
      _filterCategoryId = categoryId;
      _currentIndex = 1; // Navigate to Institutions tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final screens = [
          HomeScreen(
            repository: widget.repository,
            onNavigateTab: _onNavigateTab,
            onSelectCategory: _onSelectCategory,
          ),
          InstitutionsScreen(
            key: ValueKey('institutions_$_filterCategoryId'),
            repository: widget.repository,
            initialCategoryId: _filterCategoryId,
          ),
          EligibilityScreen(
            repository: widget.repository,
          ),
          ShortlistScreen(
            repository: widget.repository,
            onNavigateTab: _onNavigateTab,
          ),
          SettingsScreen(
            repository: widget.repository,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) {
              setState(() {
                _currentIndex = idx;
                _filterCategoryId = null;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school_rounded),
                label: 'Universities',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate_rounded),
                label: 'Eligibility',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Shortlist',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

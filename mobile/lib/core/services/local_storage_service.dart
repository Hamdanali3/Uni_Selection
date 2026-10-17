import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application_plan.dart';

class LocalStorageService {
  static const _keyShortlistInstitutions = 'shortlist_institutions';
  static const _keyShortlistProgrammes = 'shortlist_programmes';
  static const _keyShortlistScholarships = 'shortlist_scholarships';
  static const _keySelectedScope = 'selected_scope';
  static const _keyUserProfile = 'user_profile';
  static const _keyCompletedOnboarding = 'has_completed_onboarding';
  static const _keyApplicationPlans = 'application_plans';
  static const _keyNotificationPreferences = 'notification_preferences';

  final Set<String> _inMemoryInstitutions = {};
  final Set<String> _inMemoryProgrammes = {};
  final Set<String> _inMemoryScholarships = {};
  final List<ApplicationPlan> _inMemoryPlans = [];
  Map<String, dynamic> _inMemoryNotificationPrefs = {
    'reminders_enabled': true,
    'deadline_alerts_enabled': true,
    'days_before_alert': 7,
  };

  String _inMemoryScope = 'national';
  Map<String, dynamic> _inMemoryProfile = {};
  bool _inMemoryCompletedOnboarding = false;

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _inMemoryInstitutions.addAll(
        _prefs?.getStringList(_keyShortlistInstitutions) ?? [],
      );
      _inMemoryProgrammes.addAll(
        _prefs?.getStringList(_keyShortlistProgrammes) ?? [],
      );
      _inMemoryScholarships.addAll(
        _prefs?.getStringList(_keyShortlistScholarships) ?? [],
      );
      _inMemoryScope = _prefs?.getString(_keySelectedScope) ?? 'national';
      _inMemoryCompletedOnboarding = _prefs?.getBool(_keyCompletedOnboarding) ?? false;
      
      final profileStr = _prefs?.getString(_keyUserProfile);
      if (profileStr != null && profileStr.isNotEmpty) {
        _inMemoryProfile = jsonDecode(profileStr) as Map<String, dynamic>;
      }

      final plansStr = _prefs?.getString(_keyApplicationPlans);
      if (plansStr != null && plansStr.isNotEmpty) {
        final decoded = jsonDecode(plansStr) as List;
        _inMemoryPlans.clear();
        _inMemoryPlans.addAll(
          decoded.map((p) => ApplicationPlan.fromJson(p as Map<String, dynamic>)),
        );
      }

      final notifStr = _prefs?.getString(_keyNotificationPreferences);
      if (notifStr != null && notifStr.isNotEmpty) {
        _inMemoryNotificationPrefs = jsonDecode(notifStr) as Map<String, dynamic>;
      }
    } catch (_) {
      // In-memory fallback if native channels are unavailable in headless test runner
    }
  }

  Set<String> get shortlistedInstitutionIds => Set.unmodifiable(_inMemoryInstitutions);
  Set<String> get shortlistedProgrammeIds => Set.unmodifiable(_inMemoryProgrammes);
  Set<String> get shortlistedScholarshipIds => Set.unmodifiable(_inMemoryScholarships);
  List<ApplicationPlan> get applicationPlans => List.unmodifiable(_inMemoryPlans);
  Map<String, dynamic> get notificationPreferences => Map.unmodifiable(_inMemoryNotificationPrefs);
  String get selectedScope => _inMemoryScope;
  Map<String, dynamic> get userProfile => Map.unmodifiable(_inMemoryProfile);
  Map<String, dynamic>? get savedProfile => _inMemoryProfile.isEmpty ? null : Map.unmodifiable(_inMemoryProfile);
  bool get hasCompletedOnboarding => _inMemoryCompletedOnboarding;

  Future<void> setCompletedOnboarding(bool value) async {
    _inMemoryCompletedOnboarding = value;
    try {
      await _prefs?.setBool(_keyCompletedOnboarding, value);
    } catch (_) {}
  }

  Future<void> setScope(String scope) async {
    _inMemoryScope = scope;
    try {
      await _prefs?.setString(_keySelectedScope, scope);
    } catch (_) {}
  }

  Future<void> clearShortlist() async {
    _inMemoryInstitutions.clear();
    _inMemoryProgrammes.clear();
    _inMemoryScholarships.clear();
    try {
      await _prefs?.remove(_keyShortlistInstitutions);
      await _prefs?.remove(_keyShortlistProgrammes);
      await _prefs?.remove(_keyShortlistScholarships);
    } catch (_) {}
  }

  Future<bool> toggleInstitutionShortlist(String id) async {
    final contains = _inMemoryInstitutions.contains(id);
    if (contains) {
      _inMemoryInstitutions.remove(id);
    } else {
      _inMemoryInstitutions.add(id);
    }
    try {
      await _prefs?.setStringList(
        _keyShortlistInstitutions,
        _inMemoryInstitutions.toList(),
      );
    } catch (_) {}
    return !contains;
  }

  Future<bool> toggleProgrammeShortlist(String id) async {
    final contains = _inMemoryProgrammes.contains(id);
    if (contains) {
      _inMemoryProgrammes.remove(id);
    } else {
      _inMemoryProgrammes.add(id);
    }
    try {
      await _prefs?.setStringList(
        _keyShortlistProgrammes,
        _inMemoryProgrammes.toList(),
      );
    } catch (_) {}
    return !contains;
  }

  Future<bool> toggleScholarshipShortlist(String id) async {
    final contains = _inMemoryScholarships.contains(id);
    if (contains) {
      _inMemoryScholarships.remove(id);
    } else {
      _inMemoryScholarships.add(id);
    }
    try {
      await _prefs?.setStringList(
        _keyShortlistScholarships,
        _inMemoryScholarships.toList(),
      );
    } catch (_) {}
    return !contains;
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    _inMemoryProfile = profile;
    try {
      await _prefs?.setString(_keyUserProfile, jsonEncode(profile));
    } catch (_) {}
  }

  // ── Application Plans CRUD (Local-only, privacy safe) ───────────────────────

  Future<void> _persistPlans() async {
    try {
      final jsonList = _inMemoryPlans.map((p) => p.toJson()).toList();
      await _prefs?.setString(_keyApplicationPlans, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<void> saveApplicationPlan(ApplicationPlan plan) async {
    final index = _inMemoryPlans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      _inMemoryPlans[index] = plan;
    } else {
      _inMemoryPlans.add(plan);
    }
    await _persistPlans();
  }

  Future<void> deleteApplicationPlan(String planId) async {
    _inMemoryPlans.removeWhere((p) => p.id == planId);
    await _persistPlans();
  }

  Future<void> updateApplicationTask(String planId, ApplicationTask task) async {
    final planIndex = _inMemoryPlans.indexWhere((p) => p.id == planId);
    if (planIndex < 0) return;

    final plan = _inMemoryPlans[planIndex];
    final taskIndex = plan.tasks.indexWhere((t) => t.id == task.id);
    final updatedTasks = List<ApplicationTask>.from(plan.tasks);

    if (taskIndex >= 0) {
      updatedTasks[taskIndex] = task;
    } else {
      updatedTasks.add(task);
    }

    _inMemoryPlans[planIndex] = plan.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _persistPlans();
  }

  Future<void> deleteApplicationTask(String planId, String taskId) async {
    final planIndex = _inMemoryPlans.indexWhere((p) => p.id == planId);
    if (planIndex < 0) return;

    final plan = _inMemoryPlans[planIndex];
    final updatedTasks = plan.tasks.where((t) => t.id != taskId).toList();

    _inMemoryPlans[planIndex] = plan.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _persistPlans();
  }

  // ── Notification Preferences ────────────────────────────────────────────────

  Future<void> saveNotificationPreferences(Map<String, dynamic> prefs) async {
    _inMemoryNotificationPrefs = Map<String, dynamic>.from(prefs);
    try {
      await _prefs?.setString(
        _keyNotificationPreferences,
        jsonEncode(_inMemoryNotificationPrefs),
      );
    } catch (_) {}
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyShortlistInstitutions = 'shortlist_institutions';
  static const _keyShortlistProgrammes = 'shortlist_programmes';
  static const _keySelectedScope = 'selected_scope';
  static const _keyUserProfile = 'user_profile';
  static const _keyCompletedOnboarding = 'has_completed_onboarding';

  final Set<String> _inMemoryInstitutions = {};
  final Set<String> _inMemoryProgrammes = {};
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
      _inMemoryScope = _prefs?.getString(_keySelectedScope) ?? 'national';
      _inMemoryCompletedOnboarding = _prefs?.getBool(_keyCompletedOnboarding) ?? false;
      final profileStr = _prefs?.getString(_keyUserProfile);
      if (profileStr != null && profileStr.isNotEmpty) {
        _inMemoryProfile = jsonDecode(profileStr) as Map<String, dynamic>;
      }
    } catch (_) {
      // In-memory fallback if native channels are unavailable in headless test runner
    }
  }

  Set<String> get shortlistedInstitutionIds => Set.unmodifiable(_inMemoryInstitutions);
  Set<String> get shortlistedProgrammeIds => Set.unmodifiable(_inMemoryProgrammes);
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
    try {
      await _prefs?.remove(_keyShortlistInstitutions);
      await _prefs?.remove(_keyShortlistProgrammes);
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

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    _inMemoryProfile = profile;
    try {
      await _prefs?.setString(_keyUserProfile, jsonEncode(profile));
    } catch (_) {}
  }
}

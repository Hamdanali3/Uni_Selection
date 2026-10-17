import 'package:flutter/foundation.dart' hide Category;
import '../models/country.dart';
import '../models/city.dart';
import '../models/category.dart';
import '../models/discipline.dart';
import '../models/institution.dart';
import '../models/campus.dart';
import '../models/programme.dart';
import '../models/eligibility_rule.dart';
import '../models/admission.dart';
import '../models/fee_record.dart';
import '../services/dataset_loader.dart';
import '../services/local_storage_service.dart';

class UniSelectionRepository extends ChangeNotifier {
  final DatasetLoader _loader;
  final LocalStorageService _storage;

  UniSelectionRepository({
    DatasetLoader? loader,
    LocalStorageService? storage,
  })  : _loader = loader ?? DatasetLoader(),
        _storage = storage ?? LocalStorageService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<Country> _countries = [];
  List<City> _cities = [];
  List<Category> _categories = [];
  List<Discipline> _disciplines = [];
  List<Institution> _institutions = [];
  List<Campus> _campuses = [];
  List<Programme> _programmes = [];
  List<EligibilityRule> _eligibilityRules = [];
  List<Admission> _admissions = [];
  List<FeeRecord> _feeRecords = [];

  List<Country> get countries => _countries;
  List<City> get cities => _cities;
  List<Category> get categories => _categories;
  List<Discipline> get disciplines => _disciplines;
  List<Institution> get institutions => _institutions;
  List<Campus> get campuses => _campuses;
  List<Programme> get programmes => _programmes;
  List<EligibilityRule> get eligibilityRules => _eligibilityRules;
  List<Admission> get admissions => _admissions;
  List<FeeRecord> get feeRecords => _feeRecords;

  String get activeScope => _storage.selectedScope;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _storage.init();
    final data = await _loader.loadStarterData();

    _countries = (data['countries'] as List<dynamic>?)
            ?.map((e) => Country.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _cities = (data['cities'] as List<dynamic>?)
            ?.map((e) => City.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _categories = (data['categories'] as List<dynamic>?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _disciplines = (data['disciplines'] as List<dynamic>?)
            ?.map((e) => Discipline.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _institutions = (data['institutions'] as List<dynamic>?)
            ?.map((e) => Institution.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _campuses = (data['campuses'] as List<dynamic>?)
            ?.map((e) => Campus.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _programmes = (data['programmes'] as List<dynamic>?)
            ?.map((e) => Programme.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _eligibilityRules = (data['eligibility_rules'] as List<dynamic>?)
            ?.map((e) => EligibilityRule.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _admissions = (data['admissions'] as List<dynamic>?)
            ?.map((e) => Admission.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _feeRecords = (data['fee_records'] as List<dynamic>?)
            ?.map((e) => FeeRecord.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setScope(String scope) async {
    await _storage.setScope(scope);
    notifyListeners();
  }

  Future<void> refresh() async {
    notifyListeners();
  }

  List<Institution> getInstitutions({
    String? scope, // 'national', 'international', or 'all'
    String? categoryId,
    String? cityId,
    String? query,
    String? institutionType,
  }) {
    final effectiveScope = scope ?? _storage.selectedScope;

    return _institutions.where((inst) {
      // 1. Scope filter
      if (effectiveScope == 'national' && inst.countryId != 'PAK') {
        return false;
      }
      if (effectiveScope == 'international' && inst.countryId == 'PAK') {
        return false;
      }

      // 2. Category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        if (!inst.categoryIds.contains(categoryId)) {
          return false;
        }
      }

      // 3. City filter
      if (cityId != null && cityId.isNotEmpty) {
        if (inst.cityId != cityId) {
          return false;
        }
      }

      // 4. Institution Type
      if (institutionType != null && institutionType.isNotEmpty) {
        if (inst.institutionType.toLowerCase() !=
            institutionType.toLowerCase()) {
          return false;
        }
      }

      // 5. Keyword Query
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = inst.name.toLowerCase().contains(q);
        final matchShort =
            inst.shortName?.toLowerCase().contains(q) ?? false;
        final city = getCity(inst.cityId);
        final matchCity = city?.name.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchShort && !matchCity) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Institution? getInstitutionById(String id) {
    try {
      return _institutions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Campus> getCampusesForInstitution(String institutionId) {
    return _campuses.where((c) => c.institutionId == institutionId).toList();
  }

  List<Programme> getProgrammesForInstitution(String institutionId) {
    return _programmes
        .where((p) => p.institutionId == institutionId)
        .toList();
  }

  List<Programme> searchProgrammes({
    String? disciplineId,
    String? degreeLevel,
    String? query,
    String? scope,
  }) {
    final effectiveScope = scope ?? _storage.selectedScope;
    return _programmes.where((p) {
      final inst = getInstitutionById(p.institutionId);
      if (inst == null) return false;

      if (effectiveScope == 'national' && inst.countryId != 'PAK') {
        return false;
      }
      if (effectiveScope == 'international' && inst.countryId == 'PAK') {
        return false;
      }

      if (disciplineId != null &&
          disciplineId.isNotEmpty &&
          p.disciplineId != disciplineId) {
        return false;
      }

      if (degreeLevel != null &&
          degreeLevel.isNotEmpty &&
          p.degreeLevel.toLowerCase() != degreeLevel.toLowerCase()) {
        return false;
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchProg = p.name.toLowerCase().contains(q);
        final matchInst = inst.name.toLowerCase().contains(q);
        if (!matchProg && !matchInst) return false;
      }

      return true;
    }).toList();
  }

  Programme? getProgrammeById(String id) {
    try {
      return _programmes.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  EligibilityRule? getEligibilityRuleForProgramme(String programmeId) {
    try {
      return _eligibilityRules.firstWhere((e) => e.programmeId == programmeId);
    } catch (_) {
      return null;
    }
  }

  List<Admission> getAdmissionsForInstitution(String institutionId) {
    return _admissions
        .where((a) => a.institutionId == institutionId)
        .toList();
  }

  FeeRecord? getFeeRecordForProgramme(String programmeId) {
    try {
      return _feeRecords.firstWhere((f) => f.programmeId == programmeId);
    } catch (_) {
      return null;
    }
  }

  City? getCity(String? cityId) {
    if (cityId == null) return null;
    try {
      return _cities.firstWhere((c) => c.id == cityId);
    } catch (_) {
      return null;
    }
  }

  Country? getCountry(String countryId) {
    try {
      return _countries.firstWhere((c) => c.id == countryId);
    } catch (_) {
      return null;
    }
  }

  Category? getCategory(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  Discipline? getDiscipline(String disciplineId) {
    try {
      return _disciplines.firstWhere((d) => d.id == disciplineId);
    } catch (_) {
      return null;
    }
  }

  // Shortlist management
  bool isInstitutionShortlisted(String id) =>
      _storage.shortlistedInstitutionIds.contains(id);

  bool isProgrammeShortlisted(String id) =>
      _storage.shortlistedProgrammeIds.contains(id);

  Future<void> toggleInstitutionShortlist(String id) async {
    await _storage.toggleInstitutionShortlist(id);
    notifyListeners();
  }

  Future<void> toggleProgrammeShortlist(String id) async {
    await _storage.toggleProgrammeShortlist(id);
    notifyListeners();
  }

  List<Institution> getShortlistedInstitutions() {
    return _institutions
        .where((i) => _storage.shortlistedInstitutionIds.contains(i.id))
        .toList();
  }

  List<Programme> getShortlistedProgrammes() {
    return _programmes
        .where((p) => _storage.shortlistedProgrammeIds.contains(p.id))
        .toList();
  }

  // Admin / Editorial Summary
  Map<String, dynamic> getVerificationSummary() {
    final totalInst = _institutions.length;
    final verifiedInst =
        _institutions.where((i) => i.status == 'published').length;
    final totalProgrammes = _programmes.length;
    final totalRules = _eligibilityRules.length;
    final totalAdmissions = _admissions.length;
    final totalFees = _feeRecords.length;

    return {
      'totalInstitutions': totalInst,
      'publishedInstitutions': verifiedInst,
      'nationalInstitutions':
          _institutions.where((i) => i.countryId == 'PAK').length,
      'internationalInstitutions':
          _institutions.where((i) => i.countryId != 'PAK').length,
      'totalProgrammes': totalProgrammes,
      'totalEligibilityRules': totalRules,
      'totalAdmissionCycles': totalAdmissions,
      'totalFeeRecords': totalFees,
      'verificationRate': totalInst == 0
          ? 100.0
          : ((verifiedInst / totalInst) * 100).toStringAsFixed(1),
    };
  }
}

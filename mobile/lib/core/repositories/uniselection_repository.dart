import 'package:flutter/foundation.dart' hide Category;
import '../constants/app_config.dart';
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
import '../models/scholarship.dart';
import '../models/application_plan.dart';
import '../models/country_guidance.dart';
import '../models/recommendation_result.dart';
import '../services/dataset_loader.dart';
import '../services/local_storage_service.dart';
import '../services/remote_api_service.dart';
import '../services/recommendation_service.dart';
import '../services/notification_service.dart';

export '../services/remote_api_service.dart' show BackendSyncStatus;

class UniSelectionRepository extends ChangeNotifier {
  final DatasetLoader _loader;
  final LocalStorageService _storage;
  final RemoteApiService _remoteApi;
  late final RecommendationService _recommendationService;
  late final NotificationService _notificationService;

  UniSelectionRepository({
    DatasetLoader? loader,
    LocalStorageService? storage,
    RemoteApiService? remoteApi,
    RecommendationService? recommendationService,
    NotificationService? notificationService,
  })  : _loader = loader ?? DatasetLoader(),
        _storage = storage ?? LocalStorageService(),
        _remoteApi = remoteApi ?? RemoteApiService() {
    _recommendationService = recommendationService ?? RecommendationService();
    _notificationService = notificationService ?? NotificationService(storage: _storage);
  }

  RemoteApiService get remoteApi => _remoteApi;
  LocalStorageService get storage => _storage;
  RecommendationService get recommendationService => _recommendationService;
  NotificationService get notificationService => _notificationService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  BackendSyncStatus _backendStatus = BackendSyncStatus.unconfigured;
  BackendSyncStatus get backendStatus => _backendStatus;

  String? _lastBackendError;
  String? get lastBackendError => _lastBackendError;

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
  List<Scholarship> _scholarships = [];
  List<CountryGuidance> _countryGuidances = [];
  List<Map<String, dynamic>> _syncRuns = [];
  List<Map<String, dynamic>> _reviewQueue = [];

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
  List<Scholarship> get scholarships => _scholarships;
  List<CountryGuidance> get countryGuidances => _countryGuidances;
  List<Map<String, dynamic>> get syncRuns => _syncRuns;
  List<Map<String, dynamic>> get reviewQueue => _reviewQueue;

  String get activeScope => _storage.selectedScope;
  bool get hasCompletedOnboarding => _storage.hasCompletedOnboarding;
  Map<String, dynamic> get userProfile => _storage.userProfile;
  List<ApplicationPlan> get applicationPlans => _storage.applicationPlans;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _storage.init();
    await _notificationService.init();

    Map<String, dynamic>? data;

    // Dual-Mode Operation (Live Supabase REST or Resilient Offline Seed)
    if (AppConfig.isSupabaseConfigured) {
      try {
        data = await _remoteApi.fetchPublishedData();
        _backendStatus = BackendSyncStatus.connected;
        _lastBackendError = null;
      } catch (e) {
        _lastBackendError = e.toString();
        _backendStatus = BackendSyncStatus.offlineFallback;
        data = await _loader.loadStarterData();
      }
    } else {
      _backendStatus = BackendSyncStatus.offlineFallback;
      data = await _loader.loadStarterData();
    }

    _loadDataIntoState(data);
    _isInitialized = true;
    notifyListeners();
  }

  void _loadDataIntoState(Map<String, dynamic> data) {
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

    _scholarships = (data['scholarships'] as List<dynamic>?)
            ?.map((e) => Scholarship.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _countryGuidances = (data['country_guidance'] as List<dynamic>?)
            ?.map((e) => CountryGuidance.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _syncRuns = (data['sync_runs'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    _reviewQueue = (data['review_queue'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
  }

  // ── P2-01 Scholarships Finder & Management ───────────────────────────────────

  List<Scholarship> getScholarshipsForInstitution(String institutionId) {
    return _scholarships.where((s) => s.institutionId == institutionId).toList();
  }

  List<Scholarship> getScholarships({
    String? query,
    String? institutionId,
    ScholarshipFundingType? fundingType,
    ScholarshipCoverageType? coverageType,
    String? country,
    String? degreeLevel,
    String? discipline,
    bool hideClosed = false,
    bool hideStale = false,
  }) {
    return _scholarships.where((s) {
      if (institutionId != null && s.institutionId != institutionId) {
        return false;
      }
      if (fundingType != null && s.fundingType != fundingType) {
        return false;
      }
      if (coverageType != null && s.coverageType != coverageType) {
        return false;
      }
      if (country != null && country.isNotEmpty && s.country != null && s.country != 'ALL') {
        if (s.country!.toLowerCase() != country.toLowerCase()) {
          return false;
        }
      }
      if (degreeLevel != null && degreeLevel.isNotEmpty && s.degreeLevels.isNotEmpty) {
        if (!s.degreeLevels.any((lvl) => lvl.toLowerCase() == degreeLevel.toLowerCase())) {
          return false;
        }
      }
      if (discipline != null && discipline.isNotEmpty && s.discipline != null) {
        if (!s.discipline!.toLowerCase().contains(discipline.toLowerCase())) {
          return false;
        }
      }
      if (hideClosed && s.isDeadlinePassed) {
        return false;
      }
      if (hideStale && s.isStale) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = s.name.toLowerCase().contains(q);
        final matchProvider = s.providerName?.toLowerCase().contains(q) ?? false;
        final matchCoverage = s.coverageDetails.toLowerCase().contains(q);
        final inst = getInstitutionById(s.institutionId);
        final matchInst = inst != null &&
            (inst.name.toLowerCase().contains(q) ||
                (inst.shortName?.toLowerCase().contains(q) ?? false));
        if (!matchName && !matchProvider && !matchCoverage && !matchInst) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Scholarship? getScholarshipById(String id) {
    try {
      return _scholarships.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isScholarshipShortlisted(String id) =>
      _storage.shortlistedScholarshipIds.contains(id);

  Future<void> toggleScholarshipShortlist(String id) async {
    await _storage.toggleScholarshipShortlist(id);
    notifyListeners();
  }

  List<Scholarship> getShortlistedScholarships() {
    return _scholarships
        .where((s) => _storage.shortlistedScholarshipIds.contains(s.id))
        .toList();
  }

  // ── P2-03 Transparent Personalized Recommendations ──────────────────────────

  List<RecommendationResult> getPersonalizedRecommendations() {
    final activeInsts = getInstitutions();
    return _recommendationService.rankInstitutions(
      institutions: activeInsts,
      programmes: _programmes,
      eligibilityRules: _eligibilityRules,
      studentProfile: _storage.userProfile,
    );
  }

  // ── P2-04 Application Planner & Tracker (Local-only) ─────────────────────────

  Future<ApplicationPlan> createApplicationPlan({
    required String institutionId,
    String? programmeId,
    String? targetSession,
  }) async {
    final inst = getInstitutionById(institutionId);
    final prog = programmeId != null ? getProgrammeById(programmeId) : null;
    final nowIso = DateTime.now().toIso8601String();
    final planId = 'plan-${DateTime.now().millisecondsSinceEpoch}';

    // Seed default baseline milestones/tasks for student
    final defaultTasks = [
      ApplicationTask(
        id: '$planId-task-1',
        planId: planId,
        title: 'Review Published Eligibility Criteria & Prerequisite Subjects',
        category: TaskCategory.documents,
        status: TaskStatus.completed,
        createdAt: nowIso,
        completedAt: nowIso,
      ),
      ApplicationTask(
        id: '$planId-task-2',
        planId: planId,
        title: 'Prepare Attested Transcripts & Identity Verification',
        category: TaskCategory.documents,
        status: TaskStatus.pending,
        createdAt: nowIso,
      ),
      ApplicationTask(
        id: '$planId-task-3',
        planId: planId,
        title: 'Register & Complete Required Entry Test / Entrance Assessment',
        category: TaskCategory.test,
        status: TaskStatus.pending,
        createdAt: nowIso,
      ),
      ApplicationTask(
        id: '$planId-task-4',
        planId: planId,
        title: 'Submit Online Application Form via Official Admissions Portal',
        category: TaskCategory.application,
        status: TaskStatus.pending,
        createdAt: nowIso,
      ),
      ApplicationTask(
        id: '$planId-task-5',
        planId: planId,
        title: 'Track Merit List Announcement & Confirm Fee Voucher Details',
        category: TaskCategory.financial,
        status: TaskStatus.pending,
        createdAt: nowIso,
      ),
    ];

    final plan = ApplicationPlan(
      id: planId,
      institutionId: institutionId,
      programmeId: programmeId,
      institutionName: inst?.name ?? 'Target Institution',
      programmeName: prog?.name,
      targetSession: targetSession ?? 'Fall 2026',
      applicationUrl: inst?.admissionsUrl,
      createdAt: nowIso,
      tasks: defaultTasks,
    );

    await _storage.saveApplicationPlan(plan);
    notifyListeners();
    return plan;
  }

  Future<void> deleteApplicationPlan(String planId) async {
    await _storage.deleteApplicationPlan(planId);
    notifyListeners();
  }

  Future<void> addApplicationTask({
    required String planId,
    required String title,
    String? description,
    TaskCategory category = TaskCategory.other,
    String? dueDateIso,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final task = ApplicationTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      planId: planId,
      title: title,
      description: description,
      category: category,
      dueDateIso: dueDateIso,
      status: TaskStatus.pending,
      createdAt: nowIso,
    );
    await _storage.updateApplicationTask(planId, task);
    notifyListeners();
  }

  Future<void> updateApplicationTask(String planId, ApplicationTask task) async {
    await _storage.updateApplicationTask(planId, task);
    notifyListeners();
  }

  Future<void> deleteApplicationTask(String planId, String taskId) async {
    await _storage.deleteApplicationTask(planId, taskId);
    notifyListeners();
  }

  // ── P2-12 Bounded International Country Guidance ─────────────────────────────

  CountryGuidance? getCountryGuidance(String countryCode) {
    try {
      return _countryGuidances.firstWhere(
        (c) => c.countryCode.toUpperCase() == countryCode.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Editorial & Discrepancy Reporting (P2-08 & P2-09) ─────────────────────────

  void approveReviewItem(String reviewId) {
    final idx = _reviewQueue.indexWhere((item) => item['id'] == reviewId);
    if (idx != -1) {
      _reviewQueue[idx]['status'] = 'approved';
      notifyListeners();
    }
  }

  void rejectReviewItem(String reviewId) {
    final idx = _reviewQueue.indexWhere((item) => item['id'] == reviewId);
    if (idx != -1) {
      _reviewQueue[idx]['status'] = 'rejected';
      notifyListeners();
    }
  }

  Future<void> submitUserDiscrepancyReport({
    required String entityId,
    required String entityType,
    required String fieldName,
    required String reportedValue,
    required String notes,
  }) async {
    final reportMap = {
      'id': 'user-rep-${DateTime.now().millisecondsSinceEpoch}',
      'entity_id': entityId,
      'entity_type': entityType,
      'field_name': fieldName,
      'old_value': '',
      'new_value': reportedValue,
      'risk_level': 'medium',
      'diff_reason': 'User Reported Discrepancy: $notes',
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    _reviewQueue.insert(0, reportMap);
    notifyListeners();

    // Cloud submission fallback
    if (_remoteApi.isConfigured) {
      try {
        await _remoteApi.submitDiscrepancyReport(reportMap);
      } catch (_) {}
    }
  }

  Future<void> retryBackendSync() async {
    if (AppConfig.isSupabaseConfigured) {
      try {
        final data = await _remoteApi.fetchPublishedData();
        _backendStatus = BackendSyncStatus.connected;
        _lastBackendError = null;
        _loadDataIntoState(data);
        notifyListeners();
      } catch (e) {
        _lastBackendError = e.toString();
        _backendStatus = BackendSyncStatus.offlineFallback;
        notifyListeners();
      }
    } else {
      _backendStatus = BackendSyncStatus.offlineFallback;
      notifyListeners();
    }
  }

  Future<void> setScope(String scope) async {
    await _storage.setScope(scope);
    notifyListeners();
  }

  Future<void> completeOnboarding(String scope) async {
    await _storage.setScope(scope);
    await _storage.setCompletedOnboarding(true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await _storage.setCompletedOnboarding(false);
    notifyListeners();
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _storage.saveProfile(profile);
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
    String? status, // 'all', 'published', 'in_review', 'draft'
  }) {
    final effectiveScope = scope ?? _storage.selectedScope;

    return _institutions.where((inst) {
      // 1. Status filter (default to published unless admin view requests all/specific)
      if (status != null && status != 'all') {
        if (inst.status != status) return false;
      }

      // 2. Scope filter
      if (effectiveScope == 'national' && inst.countryId != 'PAK') {
        return false;
      }
      if (effectiveScope == 'international' && inst.countryId == 'PAK') {
        return false;
      }

      // 3. Category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        if (!inst.categoryIds.contains(categoryId)) {
          return false;
        }
      }

      // 4. City filter
      if (cityId != null && cityId.isNotEmpty) {
        if (inst.cityId != cityId) {
          return false;
        }
      }

      // 5. Institution Type
      if (institutionType != null && institutionType.isNotEmpty) {
        if (inst.institutionType.toLowerCase() !=
            institutionType.toLowerCase()) {
          return false;
        }
      }

      // 6. Keyword Query
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = inst.name.toLowerCase().contains(q);
        final matchShort =
            inst.shortName?.toLowerCase().contains(q) ?? false;
        final city = getCity(inst.cityId);
        final matchCity = city?.name.toLowerCase().contains(q) ?? false;
        final instProgrammes = getProgrammesForInstitution(inst.id);
        final matchProgramme = instProgrammes.any((p) =>
            p.name.toLowerCase().contains(q) ||
            p.degreeLevel.toLowerCase().contains(q));

        if (!matchName && !matchShort && !matchCity && !matchProgramme) {
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
        final matchInst = inst.name.toLowerCase().contains(q) ||
            (inst.shortName?.toLowerCase().contains(q) ?? false);
        if (!matchProg && !matchInst) return false;
      }

      return true;
    }).toList();
  }

  List<Programme> getProgrammes({
    String? disciplineId,
    String? degreeLevel,
    String? query,
    String? scope,
  }) =>
      searchProgrammes(
        disciplineId: disciplineId,
        degreeLevel: degreeLevel,
        query: query,
        scope: scope,
      );

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

  Future<void> clearShortlist() async {
    await _storage.clearShortlist();
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

  // Admin / Editorial Status Mutation
  void updateInstitutionStatus(String id, String newStatus) {
    final index = _institutions.indexWhere((i) => i.id == id);
    if (index != -1) {
      final old = _institutions[index];
      _institutions[index] = Institution(
        id: old.id,
        name: old.name,
        shortName: old.shortName,
        countryId: old.countryId,
        cityId: old.cityId,
        institutionType: old.institutionType,
        hecRecognized: old.hecRecognized,
        accreditationBody: old.accreditationBody,
        officialWebsite: old.officialWebsite,
        admissionsUrl: old.admissionsUrl,
        contactEmail: old.contactEmail,
        contactPhone: old.contactPhone,
        logoUrl: old.logoUrl,
        overview: old.overview,
        categoryIds: old.categoryIds,
        lastVerifiedAt: old.lastVerifiedAt,
        status: newStatus,
      );
      notifyListeners();
    }
  }

  // Admin / Editorial Summary & Data Quality Dashboard (P2-11)
  Map<String, dynamic> getVerificationSummary() {
    final totalInst = _institutions.length;
    final publishedInst =
        _institutions.where((i) => i.status == 'published').length;
    final inReviewInst =
        _institutions.where((i) => i.status == 'in_review').length;
    final draftInst =
        _institutions.where((i) => i.status == 'draft').length;
    final totalProgrammes = _programmes.length;
    final totalRules = _eligibilityRules.length;
    final totalAdmissions = _admissions.length;
    final totalFees = _feeRecords.length;
    final totalScholarships = _scholarships.length;
    final totalGuidance = _countryGuidances.length;

    // Detect stale records (> 180 days since lastVerifiedAt)
    final now = DateTime.now();
    int staleCount = 0;
    for (final inst in _institutions) {
      if (inst.lastVerifiedAt.isNotEmpty) {
        try {
          final dt = DateTime.parse(inst.lastVerifiedAt);
          if (now.difference(dt).inDays > 180) {
            staleCount++;
          }
        } catch (_) {}
      }
    }

    return {
      'totalInstitutions': totalInst,
      'publishedInstitutions': publishedInst,
      'inReviewInstitutions': inReviewInst,
      'draftInstitutions': draftInst,
      'staleInstitutions': staleCount,
      'nationalInstitutions':
          _institutions.where((i) => i.countryId == 'PAK').length,
      'internationalInstitutions':
          _institutions.where((i) => i.countryId != 'PAK').length,
      'totalProgrammes': totalProgrammes,
      'totalEligibilityRules': totalRules,
      'totalAdmissionCycles': totalAdmissions,
      'totalFeeRecords': totalFees,
      'totalScholarships': totalScholarships,
      'totalCountryGuidance': totalGuidance,
      'verificationRate': totalInst == 0
          ? 100.0
          : ((publishedInst / totalInst) * 100).toStringAsFixed(1),
    };
  }
}

// Phase 2 — P2-04 Application Planner & Tracker
// ApplicationPlan and ApplicationTask models — LOCAL ONLY (SharedPreferences).
// No cloud sync in Phase 2. CNIC/passport/bank data NEVER stored.

enum TaskStatus {
  pending,
  inProgress,
  completed,
  skipped,
}

enum TaskCategory {
  documents,
  test,
  application,
  financial,
  visa,
  other,
}

class ApplicationTask {
  final String id;
  final String planId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskCategory category;
  final String? dueDateIso;    // ISO 8601 date string, nullable
  final bool reminderEnabled;
  final String createdAt;
  final String? completedAt;

  const ApplicationTask({
    required this.id,
    required this.planId,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.dueDateIso,
    this.reminderEnabled = false,
    required this.createdAt,
    this.completedAt,
  });

  ApplicationTask copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskCategory? category,
    String? dueDateIso,
    bool? reminderEnabled,
    String? completedAt,
  }) {
    return ApplicationTask(
      id: id,
      planId: planId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      dueDateIso: dueDateIso ?? this.dueDateIso,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory ApplicationTask.fromJson(Map<String, dynamic> json) {
    TaskStatus parseStatus(String? s) {
      switch (s) {
        case 'inProgress': return TaskStatus.inProgress;
        case 'completed': return TaskStatus.completed;
        case 'skipped': return TaskStatus.skipped;
        default: return TaskStatus.pending;
      }
    }

    TaskCategory parseCategory(String? s) {
      switch (s) {
        case 'documents': return TaskCategory.documents;
        case 'test': return TaskCategory.test;
        case 'application': return TaskCategory.application;
        case 'financial': return TaskCategory.financial;
        case 'visa': return TaskCategory.visa;
        default: return TaskCategory.other;
      }
    }

    return ApplicationTask(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: parseStatus(json['status'] as String?),
      category: parseCategory(json['category'] as String?),
      dueDateIso: json['due_date_iso'] as String?,
      reminderEnabled: json['reminder_enabled'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'plan_id': planId,
    'title': title,
    'description': description,
    'status': status.name,
    'category': category.name,
    'due_date_iso': dueDateIso,
    'reminder_enabled': reminderEnabled,
    'created_at': createdAt,
    'completed_at': completedAt,
  };

  DateTime? get dueDate {
    if (dueDateIso == null) return null;
    try {
      return DateTime.parse(dueDateIso!);
    } catch (_) {
      return null;
    }
  }

  bool get isOverdue {
    final d = dueDate;
    if (d == null || status == TaskStatus.completed || status == TaskStatus.skipped) return false;
    return DateTime.now().isAfter(d);
  }
}

class ApplicationPlan {
  final String id;
  final String institutionId;
  final String? programmeId;
  final String institutionName;
  final String? programmeName;
  final String? targetSession;   // e.g. "Fall 2026"
  final String? applicationUrl;
  final String createdAt;
  final String? updatedAt;
  final List<ApplicationTask> tasks;

  const ApplicationPlan({
    required this.id,
    required this.institutionId,
    this.programmeId,
    required this.institutionName,
    this.programmeName,
    this.targetSession,
    this.applicationUrl,
    required this.createdAt,
    this.updatedAt,
    this.tasks = const [],
  });

  ApplicationPlan copyWith({
    String? targetSession,
    String? applicationUrl,
    String? updatedAt,
    List<ApplicationTask>? tasks,
  }) {
    return ApplicationPlan(
      id: id,
      institutionId: institutionId,
      programmeId: programmeId,
      institutionName: institutionName,
      programmeName: programmeName,
      targetSession: targetSession ?? this.targetSession,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tasks: tasks ?? this.tasks,
    );
  }

  int get completedTaskCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  int get totalTaskCount => tasks.length;

  double get progress =>
      totalTaskCount == 0 ? 0.0 : completedTaskCount / totalTaskCount;

  factory ApplicationPlan.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'];
    final List<ApplicationTask> tasks = rawTasks is List
        ? rawTasks
            .map((t) => ApplicationTask.fromJson(t as Map<String, dynamic>))
            .toList()
        : [];

    return ApplicationPlan(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      programmeId: json['programme_id'] as String?,
      institutionName: json['institution_name'] as String,
      programmeName: json['programme_name'] as String?,
      targetSession: json['target_session'] as String?,
      applicationUrl: json['application_url'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      tasks: tasks,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution_id': institutionId,
    'programme_id': programmeId,
    'institution_name': institutionName,
    'programme_name': programmeName,
    'target_session': targetSession,
    'application_url': applicationUrl,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };
}

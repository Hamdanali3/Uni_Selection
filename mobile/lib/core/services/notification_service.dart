// Phase 2 — P2-06 Reminder & Notification System
// Local notification manager with safe cross-platform fallback.
// In Phase 2: Local reminders only (no FCM/APNS remote push servers required).
// Supports scheduling, listing, and canceling deadline reminders.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class ScheduledReminder {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledDateTime;
  final String entityId;
  final String entityType; // 'admission', 'scholarship', 'task'

  const ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDateTime,
    required this.entityId,
    required this.entityType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduled_date_time': scheduledDateTime.toIso8601String(),
    'entity_id': entityId,
    'entity_type': entityType,
  };

  factory ScheduledReminder.fromJson(Map<String, dynamic> json) {
    return ScheduledReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledDateTime: DateTime.parse(json['scheduled_date_time'] as String),
      entityId: json['entity_id'] as String,
      entityType: json['entity_type'] as String,
    );
  }
}

class NotificationService {
  final LocalStorageService storage;
  final List<ScheduledReminder> _scheduledReminders = [];

  NotificationService({required this.storage});

  List<ScheduledReminder> get scheduledReminders => List.unmodifiable(_scheduledReminders);

  bool get areRemindersEnabled =>
      storage.notificationPreferences['reminders_enabled'] as bool? ?? true;

  int get defaultDaysBeforeAlert =>
      storage.notificationPreferences['days_before_alert'] as int? ?? 7;

  Future<void> init() async {
    // Service initialized
  }

  /// Schedules a deadline reminder for an admissions cycle, scholarship, or task.
  Future<bool> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime targetDeadline,
    required String entityId,
    required String entityType,
    int? daysBefore,
  }) async {
    if (!areRemindersEnabled) {
      debugPrint('[NotificationService] Reminders are disabled by student preference.');
      return false;
    }

    final leadDays = daysBefore ?? defaultDaysBeforeAlert;
    final scheduledDate = targetDeadline.subtract(Duration(days: leadDays));

    // Cancel existing reminder for the same entity if already scheduled
    await cancelReminderForEntity(entityId);

    final reminder = ScheduledReminder(
      id: id,
      title: title,
      body: body,
      scheduledDateTime: scheduledDate,
      entityId: entityId,
      entityType: entityType,
    );

    _scheduledReminders.add(reminder);
    debugPrint('[NotificationService] Scheduled reminder for "$title" on $scheduledDate');
    return true;
  }

  /// Cancels a scheduled reminder by its reminder ID.
  Future<void> cancelReminder(String id) async {
    _scheduledReminders.removeWhere((r) => r.id == id);
    debugPrint('[NotificationService] Canceled reminder: $id');
  }

  /// Cancels all scheduled reminders linked to an entity ID.
  Future<void> cancelReminderForEntity(String entityId) async {
    _scheduledReminders.removeWhere((r) => r.entityId == entityId);
  }

  /// Checks if a reminder is active for a given entity.
  bool hasActiveReminder(String entityId) {
    return _scheduledReminders.any((r) => r.entityId == entityId);
  }
}

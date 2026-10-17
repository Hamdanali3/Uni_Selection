// Phase 2 — P2-05 Admissions Calendar & Deadline View
// Aggregates admission cycles, scholarship deadlines, and user application tasks
// into a unified chronological calendar timeline with reminder scheduling.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/repositories/uniselection_repository.dart';
import '../institutions/institution_detail_screen.dart';
import '../scholarships/scholarship_detail_screen.dart';

enum DeadlineType {
  admission,
  scholarship,
  userTask,
}

class CalendarDeadlineItem {
  final String id;
  final String title;
  final String subtitle;
  final String dateIso;
  final DeadlineType type;
  final String entityId;

  const CalendarDeadlineItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateIso,
    required this.type,
    required this.entityId,
  });

  DateTime? get date {
    try {
      return DateTime.parse(dateIso);
    } catch (_) {
      return null;
    }
  }

  bool get isUpcoming {
    final d = date;
    if (d == null) return false;
    return d.isAfter(DateTime.now());
  }
}

class AdmissionsCalendarScreen extends StatefulWidget {
  final UniSelectionRepository repository;

  const AdmissionsCalendarScreen({
    super.key,
    required this.repository,
  });

  @override
  State<AdmissionsCalendarScreen> createState() => _AdmissionsCalendarScreenState();
}

class _AdmissionsCalendarScreenState extends State<AdmissionsCalendarScreen> {
  DeadlineType? _filterType;

  List<CalendarDeadlineItem> _aggregateDeadlines() {
    final items = <CalendarDeadlineItem>[];

    // 1. Admission cycles
    for (final adm in widget.repository.admissions) {
      final inst = widget.repository.getInstitutionById(adm.institutionId);
      final instName = inst?.shortName ?? inst?.name ?? 'University';
      if (adm.closingDate != null && adm.closingDate!.isNotEmpty) {
        items.add(CalendarDeadlineItem(
          id: 'adm-${adm.id}',
          title: '$instName: ${adm.sessionName} Admissions Deadline',
          subtitle: 'Cycle: ${adm.sessionName} • Status: ${adm.admissionStatus}',
          dateIso: adm.closingDate!,
          type: DeadlineType.admission,
          entityId: adm.institutionId,
        ));
      }
    }

    // 2. Scholarships
    for (final s in widget.repository.scholarships) {
      if (s.applicationDeadline != null && s.applicationDeadline!.isNotEmpty) {
        final inst = widget.repository.getInstitutionById(s.institutionId);
        final instName = s.providerName ?? inst?.shortName ?? inst?.name ?? 'Scholarship';
        items.add(CalendarDeadlineItem(
          id: 'sch-${s.id}',
          title: '${s.name} Application Deadline',
          subtitle: 'Provider: $instName • ${s.coverageType.name.toUpperCase()}',
          dateIso: s.applicationDeadline!,
          type: DeadlineType.scholarship,
          entityId: s.id,
        ));
      }
    }

    // 3. User Application Tasks
    for (final plan in widget.repository.applicationPlans) {
      for (final task in plan.tasks) {
        if (task.dueDateIso != null && task.dueDateIso!.isNotEmpty) {
          items.add(CalendarDeadlineItem(
            id: 'task-${task.id}',
            title: '${plan.institutionName}: ${task.title}',
            subtitle: 'Category: ${task.category.name.toUpperCase()}',
            dateIso: task.dueDateIso!,
            type: DeadlineType.userTask,
            entityId: plan.id,
          ));
        }
      }
    }

    // Filter by type if selected
    var filtered = _filterType != null
        ? items.where((i) => i.type == _filterType).toList()
        : items;

    // Sort chronologically
    filtered.sort((a, b) {
      final da = a.date ?? DateTime(2099);
      final db = b.date ?? DateTime(2099);
      return da.compareTo(db);
    });

    return filtered;
  }

  void _toggleReminder(CalendarDeadlineItem item) async {
    final notif = widget.repository.notificationService;
    final isAlready = notif.hasActiveReminder(item.entityId);

    if (isAlready) {
      await notif.cancelReminderForEntity(item.entityId);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder cancelled.')),
        );
      }
    } else {
      final d = item.date ?? DateTime.now().add(const Duration(days: 14));
      final success = await notif.scheduleReminder(
        id: 'rem-${item.id}',
        title: item.title,
        body: 'Deadline on ${item.dateIso}. Ensure all forms and fee vouchers are submitted.',
        targetDeadline: d,
        entityId: item.entityId,
        entityType: item.type.name,
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Reminder scheduled for ${item.title}' : 'Reminders are disabled in Settings.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _aggregateDeadlines();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions Calendar'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(label: 'All Deadlines', type: null),
                  const SizedBox(width: 8),
                  _filterChip(label: 'Admissions', type: DeadlineType.admission),
                  const SizedBox(width: 8),
                  _filterChip(label: 'Scholarships', type: DeadlineType.scholarship),
                  const SizedBox(width: 8),
                  _filterChip(label: 'My Tasks', type: DeadlineType.userTask),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Timeline count banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceVariant.withAlpha(80),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${items.length} Chronological Deadline Event(s)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          const Text('No Deadlines Scheduled', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text('Active admission intakes and scholarship deadlines will appear here automatically.',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final hasReminder = widget.repository.notificationService.hasActiveReminder(item.entityId);

                      Color typeColor;
                      IconData typeIcon;
                      String typeBadge;

                      switch (item.type) {
                        case DeadlineType.admission:
                          typeColor = AppColors.primary;
                          typeIcon = Icons.school_rounded;
                          typeBadge = 'ADMISSION';
                          break;
                        case DeadlineType.scholarship:
                          typeColor = AppColors.secondary;
                          typeIcon = Icons.stars_rounded;
                          typeBadge = 'SCHOLARSHIP';
                          break;
                        case DeadlineType.userTask:
                          typeColor = Colors.teal;
                          typeIcon = Icons.task_alt_rounded;
                          typeBadge = 'MY TASK';
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: typeColor.withAlpha(30),
                            child: Icon(typeIcon, color: typeColor, size: 20),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: typeColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(typeBadge, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: typeColor)),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.dateIso,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              hasReminder ? Icons.notifications_active : Icons.notification_add_outlined,
                              color: hasReminder ? AppColors.secondary : AppColors.textSecondary,
                            ),
                            tooltip: hasReminder ? 'Reminder Active' : 'Set Reminder',
                            onPressed: () => _toggleReminder(item),
                          ),
                          onTap: () {
                            if (item.type == DeadlineType.admission) {
                              final inst = widget.repository.getInstitutionById(item.entityId);
                              if (inst != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InstitutionDetailScreen(
                                      institution: inst,
                                      repository: widget.repository,
                                    ),
                                  ),
                                );
                              }
                            } else if (item.type == DeadlineType.scholarship) {
                              final s = widget.repository.getScholarshipById(item.entityId);
                              if (s != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScholarshipDetailScreen(
                                      scholarship: s,
                                      repository: widget.repository,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required DeadlineType? type}) {
    final isSelected = _filterType == type;
    return FilterChip(
      selected: isSelected,
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onSelected: (_) {
        setState(() {
          _filterType = type;
        });
      },
    );
  }
}

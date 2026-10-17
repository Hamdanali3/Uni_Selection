// Phase 2 — P2-04 Application Planner & Tracker Screen
// Privacy-first local admissions milestone tracking, task checklist,
// deadline notifications, and progress visualization.
// Zero cloud sync — all data stored locally on device.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/application_plan.dart';
import '../../core/repositories/uniselection_repository.dart';

class ApplicationPlannerScreen extends StatefulWidget {
  final UniSelectionRepository repository;

  const ApplicationPlannerScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ApplicationPlannerScreen> createState() => _ApplicationPlannerScreenState();
}

class _ApplicationPlannerScreenState extends State<ApplicationPlannerScreen> {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showCreatePlanDialog() {
    final institutions = widget.repository.institutions;
    if (institutions.isEmpty) return;

    String selectedInstId = institutions.first.id;
    String? selectedProgId;
    final sessionController = TextEditingController(text: 'Fall 2026');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final progs = widget.repository.getProgrammesForInstitution(selectedInstId);

          return AlertDialog(
            title: const Text('New Application Plan', style: TextStyle(fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Target University:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedInstId,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: institutions.map((i) {
                      return DropdownMenuItem(
                        value: i.id,
                        child: Text(i.shortName ?? i.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedInstId = val;
                          selectedProgId = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (progs.isNotEmpty) ...[
                    const Text('Target Programme (Optional):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: selectedProgId,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('General Application', style: TextStyle(fontSize: 13))),
                        ...progs.map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} (${p.degreeLevel})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                            )),
                      ],
                      onChanged: (val) => setDialogState(() => selectedProgId = val),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text('Target Admission Intake:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: sessionController,
                    decoration: const InputDecoration(hintText: 'e.g. Fall 2026, Spring 2027'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await widget.repository.createApplicationPlan(
                    institutionId: selectedInstId,
                    programmeId: selectedProgId,
                    targetSession: sessionController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) setState(() {});
                },
                child: const Text('Create Plan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(String planId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskCategory selectedCat = TaskCategory.documents;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Milestone Task', style: TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title *', hintText: 'e.g. Submit Entry Test Scores'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Details (Optional)'),
                ),
                const SizedBox(height: 12),
                const Text('Category:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<TaskCategory>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  items: TaskCategory.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCat = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  await widget.repository.addApplicationTask(
                    planId: planId,
                    title: titleController.text.trim(),
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                    category: selectedCat,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) setState(() {});
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = widget.repository.applicationPlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Add Target University Plan',
            onPressed: _showCreatePlanDialog,
          ),
        ],
      ),
      body: plans.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Privacy notice banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withAlpha(60)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.secondary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your application plans and checklists are stored locally on your device. No identity or application data is transmitted.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List of Plans
                ...plans.map((plan) => _buildPlanCard(plan)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlanDialog,
        icon: const Icon(Icons.add),
        label: const Text('Track University'),
      ),
    );
  }

  Widget _buildPlanCard(ApplicationPlan plan) {
    final progressPct = (plan.progress * 100).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.institutionName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.programmeName ?? "Undergraduate Admissions"} • ${plan.targetSession ?? "Fall 2026"}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusError, size: 20),
                  tooltip: 'Delete Plan',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Application Plan?'),
                        content: Text('Remove ${plan.institutionName} and its checklist?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () async {
                              await widget.repository.deleteApplicationPlan(plan.id);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) setState(() {});
                            },
                            child: const Text('Delete', style: TextStyle(color: AppColors.statusError)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: plan.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      color: plan.progress == 1.0 ? AppColors.verifiedBadge : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$progressPct% (${plan.completedTaskCount}/${plan.totalTaskCount})',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),

            const Divider(height: 24),

            // Task Checklist
            ...plan.tasks.map((task) => _buildTaskItem(plan.id, task)),

            const SizedBox(height: 8),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddTaskDialog(plan.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Milestone', style: TextStyle(fontSize: 12)),
                ),
                if (plan.applicationUrl != null && plan.applicationUrl!.isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl(plan.applicationUrl!),
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: const Text('Admissions Portal', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String planId, ApplicationTask task) {
    final isDone = task.status == TaskStatus.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isDone,
            activeColor: AppColors.verifiedBadge,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) async {
              final newStatus = (val ?? false) ? TaskStatus.completed : TaskStatus.pending;
              final updated = task.copyWith(
                status: newStatus,
                completedAt: newStatus == TaskStatus.completed ? DateTime.now().toIso8601String() : null,
              );
              await widget.repository.updateApplicationTask(planId, updated);
              if (mounted) setState(() {});
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isDone ? FontWeight.w500 : FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            tooltip: 'Remove Task',
            onPressed: () async {
              await widget.repository.deleteApplicationTask(planId, task.id);
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Tracked Applications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your target universities to build personalized checklists, track admission milestones, and monitor deadlines.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _showCreatePlanDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Start Tracking a University'),
            ),
          ],
        ),
      ),
    );
  }
}

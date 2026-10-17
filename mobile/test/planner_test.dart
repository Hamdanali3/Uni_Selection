import 'package:flutter_test/flutter_test.dart';
import 'package:uniselection/core/models/application_plan.dart';
import 'package:uniselection/core/repositories/uniselection_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 — Application Planner & Tracker Tests (P2-04)', () {
    test('ApplicationPlan progress calculation and milestone completion', () {
      final now = DateTime.now().toIso8601String();
      const plan = ApplicationPlan(
        id: 'plan-1',
        institutionId: 'nust',
        institutionName: 'NUST Islamabad',
        targetSession: 'Fall 2026',
        createdAt: '2026-10-15',
        tasks: [
          ApplicationTask(
            id: 't-1',
            planId: 'plan-1',
            title: 'Prepare transcripts',
            status: TaskStatus.completed,
            createdAt: '2026-10-15',
          ),
          ApplicationTask(
            id: 't-2',
            planId: 'plan-1',
            title: 'Register for entrance test',
            status: TaskStatus.pending,
            createdAt: '2026-10-15',
          ),
          ApplicationTask(
            id: 't-3',
            planId: 'plan-1',
            title: 'Pay application fee',
            status: TaskStatus.pending,
            createdAt: '2026-10-15',
          ),
          ApplicationTask(
            id: 't-4',
            planId: 'plan-1',
            title: 'Submit online form',
            status: TaskStatus.pending,
            createdAt: '2026-10-15',
          ),
        ],
      );

      expect(plan.totalTaskCount, 4);
      expect(plan.completedTaskCount, 1);
      expect(plan.progress, 0.25);

      // Complete another task
      final updatedTasks = List<ApplicationTask>.from(plan.tasks);
      updatedTasks[1] = updatedTasks[1].copyWith(
        status: TaskStatus.completed,
        completedAt: now,
      );

      final updatedPlan = plan.copyWith(tasks: updatedTasks);
      expect(updatedPlan.completedTaskCount, 2);
      expect(updatedPlan.progress, 0.5);
    });

    test('ApplicationTask overdue calculation works accurately', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3)).toIso8601String();
      final futureDate = DateTime.now().add(const Duration(days: 10)).toIso8601String();

      final overdueTask = ApplicationTask(
        id: 't-overdue',
        planId: 'plan-1',
        title: 'Past Due Milestone',
        dueDateIso: pastDate,
        status: TaskStatus.pending,
        createdAt: '2026-10-01',
      );
      expect(overdueTask.isOverdue, isTrue);

      final upcomingTask = ApplicationTask(
        id: 't-upcoming',
        planId: 'plan-1',
        title: 'Future Milestone',
        dueDateIso: futureDate,
        status: TaskStatus.pending,
        createdAt: '2026-10-01',
      );
      expect(upcomingTask.isOverdue, isFalse);

      // Completed tasks are never overdue
      final completedPastTask = overdueTask.copyWith(status: TaskStatus.completed);
      expect(completedPastTask.isOverdue, isFalse);
    });

    test('UniSelectionRepository creates, updates, and deletes application plans locally', () async {
      final repo = UniSelectionRepository();
      await repo.initialize();

      final initialCount = repo.applicationPlans.length;

      // Create new plan
      final newPlan = await repo.createApplicationPlan(
        institutionId: 'nust',
        targetSession: 'Spring 2027',
      );

      expect(repo.applicationPlans.length, initialCount + 1);
      expect(newPlan.institutionId, 'nust');
      expect(newPlan.tasks.length, 5); // 5 seeded default milestones

      // Add custom task
      await repo.addApplicationTask(
        planId: newPlan.id,
        title: 'Custom Scholarship Essay',
        category: TaskCategory.documents,
      );

      final fetchedPlan = repo.applicationPlans.firstWhere((p) => p.id == newPlan.id);
      expect(fetchedPlan.tasks.length, 6);
      expect(fetchedPlan.tasks.any((t) => t.title == 'Custom Scholarship Essay'), isTrue);

      // Delete plan
      await repo.deleteApplicationPlan(newPlan.id);
      expect(repo.applicationPlans.any((p) => p.id == newPlan.id), isFalse);
    });
  });
}

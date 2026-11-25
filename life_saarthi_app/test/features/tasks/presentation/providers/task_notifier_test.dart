import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_saarthi_app/features/tasks/data/models/task.dart';
import 'package:life_saarthi_app/features/tasks/presentation/providers/task_notifier.dart';
import 'package:life_saarthi_app/features/tasks/presentation/providers/task_repository_provider.dart';

import '../../fakes/fake_task_repository.dart';

Task createTask({
  required String id,
  String title = 'Test task',
  TaskStatus status = TaskStatus.pending,
  DateTime? completedAt,
}) {
  return Task(
    id: id,
    title: title,
    priority: TaskPriority.medium,
    status: status,
    createdAt: DateTime.utc(2026, 11, 24),
    completedAt: completedAt,
  );
}

void main() {
  group('TaskNotifier', () {
    late FakeTaskRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeTaskRepository();

      container = ProviderContainer(
        overrides: [taskRepositoryProvider.overrideWithValue(repository)],
      );

      addTearDown(container.dispose);
    });

    TaskNotifier notifier() {
      return container.read(taskNotifierProvider.notifier);
    }

    List<Task> currentTasks() {
      return container.read(taskNotifierProvider).requireValue;
    }

    // TEST 1: Empty repository
    test('Should load an empty task list', () async {
      final tasks = await container.read(taskNotifierProvider.future);

      expect(tasks, isEmpty);
      expect(container.read(taskNotifierProvider).hasValue, isTrue);
    });

    // TEST 2: Existing tasks
    test('Should load existing tasks', () async {
      await repository.insertTask(createTask(id: 'A'));
      await repository.insertTask(createTask(id: 'B'));

      final tasks = await container.read(taskNotifierProvider.future);

      expect(tasks, hasLength(2));
      expect(tasks.map((task) => task.id), unorderedEquals(['A', 'B']));
    });

    // TEST 3: Add task
    test('Should add a new task', () async {
      await container.read(taskNotifierProvider.future);

      final task = createTask(id: 'A');

      await notifier().addTask(task);

      expect(currentTasks(), hasLength(1));
      expect(currentTasks().single.id, 'A');

      final savedTasks = await repository.getTasks();

      expect(savedTasks, hasLength(1));
      expect(savedTasks.single.id, 'A');
    });

    // TEST 4: Update task
    test('Should update an existing task', () async {
      final task = createTask(id: 'A');

      await repository.insertTask(task);
      await container.read(taskNotifierProvider.future);

      final updatedTask = task.copyWith(
        title: 'Updated task',
        priority: TaskPriority.high,
      );

      await notifier().updateTask(updatedTask);

      expect(currentTasks(), hasLength(1));
      expect(currentTasks().single.title, 'Updated task');
      expect(currentTasks().single.priority, TaskPriority.high);

      final savedTasks = await repository.getTasks();

      expect(savedTasks.single.title, 'Updated task');
      expect(savedTasks.single.priority, TaskPriority.high);
    });

    // TEST 5: Complete task
    test('Should complete a pending task', () async {
      final task = createTask(id: 'A');

      await repository.insertTask(task);
      await container.read(taskNotifierProvider.future);

      await notifier().toggleTask(task);

      final completedTask = currentTasks().single;

      expect(completedTask.status, TaskStatus.completed);
      expect(completedTask.completedAt, isNotNull);
      expect(completedTask.completedAt!.isUtc, isTrue);

      final savedTasks = await repository.getTasks();

      expect(savedTasks.single.status, TaskStatus.completed);
      expect(savedTasks.single.completedAt, completedTask.completedAt);
    });

    // TEST 6: Reopen task
    test('Should reopen a completed task', () async {
      final task = createTask(
        id: 'A',
        status: TaskStatus.completed,
        completedAt: DateTime.utc(2026, 11, 24),
      );

      await repository.insertTask(task);
      await container.read(taskNotifierProvider.future);

      await notifier().toggleTask(task);

      final reopenedTask = currentTasks().single;

      expect(reopenedTask.status, TaskStatus.pending);
      expect(reopenedTask.completedAt, isNull);

      final savedTasks = await repository.getTasks();

      expect(savedTasks.single.status, TaskStatus.pending);
      expect(savedTasks.single.completedAt, isNull);
    });

    // TEST 7: Delete task
    test('Should delete the selected task', () async {
      await repository.insertTask(createTask(id: 'A'));
      await repository.insertTask(createTask(id: 'B'));

      await container.read(taskNotifierProvider.future);

      await notifier().deleteTask('A');

      expect(currentTasks(), hasLength(1));
      expect(currentTasks().single.id, 'B');

      final savedTasks = await repository.getTasks();

      expect(savedTasks, hasLength(1));
      expect(savedTasks.single.id, 'B');
    });

    // TEST 8: Refresh tasks
    test('Should refresh tasks from repository', () async {
      await repository.insertTask(createTask(id: 'A'));

      await container.read(taskNotifierProvider.future);

      expect(currentTasks(), hasLength(1));

      await repository.insertTask(createTask(id: 'B'));

      await notifier().refreshTasks();

      expect(currentTasks(), hasLength(2));
      expect(
        currentTasks().map((task) => task.id),
        unorderedEquals(['A', 'B']),
      );
    });
    test('Should preserve tasks during concurrent additions', () async {
      // Arrange
      await repository.insertTask(createTask(id: 'A'));

      await container.read(taskNotifierProvider.future);

      final taskB = createTask(id: 'B');
      final taskC = createTask(id: 'C');

      // Act
      await Future.wait([notifier().addTask(taskB), notifier().addTask(taskC)]);

      // Assert repository data
      final savedTasks = await repository.getTasks();

      expect(
        savedTasks.map((task) => task.id),
        unorderedEquals(['A', 'B', 'C']),
      );

      // Assert Riverpod state
      expect(
        currentTasks().map((task) => task.id),
        unorderedEquals(['A', 'B', 'C']),
      );
    });
    test('Should preserve concurrent task updates', () async {
      final taskA = createTask(id: 'A');
      final taskB = createTask(id: 'B');

      await repository.insertTask(taskA);
      await repository.insertTask(taskB);

      await container.read(taskNotifierProvider.future);

      await Future.wait([
        notifier().updateTask(taskA.copyWith(title: 'Updated A')),
        notifier().updateTask(taskB.copyWith(title: 'Updated B')),
      ]);

      expect(
        currentTasks().map((task) => task.title),
        unorderedEquals(['Updated A', 'Updated B']),
      );
    });
    test('Should preserve concurrent task completions', () async {
      final taskA = createTask(id: 'A');
      final taskB = createTask(id: 'B');

      await repository.insertTask(taskA);
      await repository.insertTask(taskB);

      await container.read(taskNotifierProvider.future);

      await Future.wait([
        notifier().toggleTask(taskA),
        notifier().toggleTask(taskB),
      ]);

      expect(currentTasks(), hasLength(2));

      expect(currentTasks().every((task) => task.isCompleted), isTrue);

      expect(currentTasks().every((task) => task.completedAt != null), isTrue);
    });
    test('Should preserve concurrent task deletions', () async {
      await repository.insertTask(createTask(id: 'A'));
      await repository.insertTask(createTask(id: 'B'));
      await repository.insertTask(createTask(id: 'C'));

      await container.read(taskNotifierProvider.future);

      await Future.wait([
        notifier().deleteTask('A'),
        notifier().deleteTask('B'),
      ]);

      expect(currentTasks(), hasLength(1));
      expect(currentTasks().single.id, 'C');

      final savedTasks = await repository.getTasks();

      expect(savedTasks, hasLength(1));
      expect(savedTasks.single.id, 'C');
    });
    test('Should preserve existing tasks when insertion fails', () async {
      // Arrange
      await repository.insertTask(createTask(id: 'A'));

      await container.read(taskNotifierProvider.future);

      repository.shouldFailInsert = true;

      // Act and assert
      await expectLater(
        notifier().addTask(createTask(id: 'B')),
        throwsA(isA<Exception>()),
      );

      // Verify existing state
      expect(container.read(taskNotifierProvider).hasError, isFalse);

      expect(currentTasks(), hasLength(1));
      expect(currentTasks().single.id, 'A');

      // Verify repository data
      final savedTasks = await repository.getTasks();

      expect(savedTasks, hasLength(1));
      expect(savedTasks.single.id, 'A');
    });
  });
}

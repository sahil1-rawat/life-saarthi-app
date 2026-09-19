import 'package:sqflite/sqflite.dart';

import '../../../../core/services/database_service.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<void> insertTask(Task task) async {
    final db = await _databaseService.database;

    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority.name,
      'status': task.status.name,
      'created_at': task.createdAt.toUtc().toIso8601String(),
      'due_date': task.dueDate?.toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    final db = await _databaseService.database;

    final rows = await db.query('tasks', orderBy: 'created_at DESC');

    return rows.map(_fromDatabase).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await _databaseService.database;

    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'status': task.status.name,
        'due_date': task.dueDate?.toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await _databaseService.database;

    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Task _fromDatabase(Map<String, dynamic> row) {
    return Task(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      priority: TaskPriority.values.byName(row['priority'] as String),
      status: TaskStatus.values.byName(row['status'] as String),
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      dueDate: row['due_date'] == null
          ? null
          : DateTime.parse(row['due_date'] as String).toUtc(),
    );
  }
}

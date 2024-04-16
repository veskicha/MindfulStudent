import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/tasks.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.completed).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.completed).toList();

  Future<void> fetchTasks() async {
    _tasks.clear();
    _tasks.addAll(await TaskManager.fetchAllTasks());

    notifyListeners();
  }

  void addTask(String title) async {
    final newTask = await TaskManager.createTask(title);
    if (newTask != null) {
      _tasks.add(newTask);
      notifyListeners();
    } else {
      log("Error adding task: Unable to create task");
    }
  }

  void toggleTaskCompletion(Task task) async {
    late final Future<void> fut;
    if (task.completed) {
      fut = task.markAsPending();
    } else {
      fut = task.markAsCompleted();
    }
    notifyListeners();

    await fut;
  }

  void updateTaskReminder(Task task, String? newReminder) async {
    task.reminder = newReminder;
    notifyListeners();

    await task.updateReminder(newReminder);
  }

  void deleteTask(Task task) async {
    _tasks.remove(task);
    notifyListeners();

    await task.delete();
  }
}

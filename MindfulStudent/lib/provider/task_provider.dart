import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/tasks.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _pendingTasks = [];
  final List<Task> _completedTasks = [];

  List<Task> get pendingTasks => _pendingTasks;

  List<Task> get completedTasks => _completedTasks;

  Future<void> fetchTasks() async {
    _pendingTasks.clear();
    _completedTasks.clear();

    final tasks = await TaskManager.fetchAllTasks();
    for (final task in tasks) {
      if (task.completed) {
        _completedTasks.add(task);
      } else {
        _pendingTasks.add(task);
      }
    }

    notifyListeners();
  }

  void addTask(String title) async {
    final newTask = await TaskManager.createTask(title);
    if (newTask != null) {
      _pendingTasks.add(newTask);
      notifyListeners();
    } else {
      log("Error adding task: Unable to create task");
    }
  }

  void toggleTaskCompletion(Task task) async {
    task.completed = !task.completed;
    if (task.completed) {
      _pendingTasks.remove(task);
      _completedTasks.add(task);
    } else {
      _completedTasks.remove(task);
      _pendingTasks.add(task);
    }
    await task.save();
    notifyListeners();
  }

  void updateTaskReminder(Task task, String newReminder) async {
    task.reminder = newReminder;
    await task.updateReminder(newReminder);
    notifyListeners();
  }

  void deleteTask(Task task) async {
    await task.delete();
    if (task.completed) {
      _completedTasks.remove(task);
    } else {
      _pendingTasks.remove(task);
    }
    notifyListeners();
  }
}

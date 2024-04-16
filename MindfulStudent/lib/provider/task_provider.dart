import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
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

    await _updateNotifications();
  }

  void addTask(String title) async {
    final newTask = await TaskManager.createTask(title);
    if (newTask != null) {
      _tasks.add(newTask);
      notifyListeners();
    } else {
      log("Error adding task: Unable to create task");
    }

    await _updateNotifications();
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

    await _updateNotifications();
  }

  void updateTaskReminder(Task task, String? newReminder) async {
    task.reminder = newReminder;
    notifyListeners();

    await task.updateReminder(newReminder);

    await _updateNotifications();
  }

  void deleteTask(Task task) async {
    _tasks.remove(task);
    notifyListeners();

    await task.delete();

    await _updateNotifications();
  }

  Future<void> _updateNotifications() async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: "task-reminder",
        channelName: "Task reminders",
        channelDescription: "Automated reminders to do your daily tasks",
      ),
    );

    log("Clearing pending task notifications");
    await AwesomeNotifications().cancelSchedulesByChannelKey("task-reminder");

    int id = 0;
    for (final task in _tasks) {
      if (task.completed) continue;

      late final NotificationCalendar schedule;
      if (task.reminder == "DAILY") {
        // Daily at 8 pm
        schedule = NotificationCalendar(
          hour: 20,
          allowWhileIdle: true,
          repeats: true,
        );
      } else if (task.reminder == "WEEKLY") {
        // Weekly at last day, noon
        schedule = NotificationCalendar(
          weekday: 7,
          hour: 12,
          allowWhileIdle: true,
          repeats: true,
        );
      } else if (task.reminder == "MONTHLY") {
        // Monthly at 28th day, noon
        schedule = NotificationCalendar(
          day: 28,
          hour: 12,
          allowWhileIdle: true,
          repeats: true,
        );
      } else {
        return;
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: "task-reminder",
          title: "Task reminder",
          body: "Don't forget! ${task.title}",
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
        ),
        schedule: schedule,
      );
      id++;

      log("Scheduled reminder for task: ${task.title}");
    }
  }
}

import 'dart:developer';

import 'package:mindfulstudent/main.dart';

class Task {
  final String id;
  final String title;
  DateTime? completedAt;
  String? reminder;

  Task(this.id, this.title, this.completedAt, this.reminder);

  static Task fromRowData(Map<String, dynamic> row) {
    final String id = row["id"];
    final String title = row["title"];
    final String? completedAt = row["completed_at"];
    final String? reminder = row["reminder"];

    return Task(
      id,
      title,
      completedAt == null ? null : DateTime.parse(completedAt).toLocal(),
      reminder,
    );
  }

  bool get completed {
    final now = DateTime.now();
    final comp = completedAt;

    if (comp == null) return false;

    if (reminder == "DAILY") {
      // Not completed if the day is different
      return now.year == comp.year &&
          now.month == comp.month &&
          now.day == comp.day;
    } else if (reminder == "WEEKLY") {
      // Not completed if not done yet this week
      final weekStart = now
          .copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          )
          .subtract(Duration(days: now.weekday - 1));
      return comp.isAfter(weekStart);
    } else if (reminder == "MONTHLY") {
      return now.year == comp.year && now.month == comp.month;
    }

    return true;
  }

  Future<void> markAsCompleted() async {
    completedAt = DateTime.now();
    await supabase
        .from("tasks")
        .update({"completed_at": completedAt.toString()}).eq("id", id);
  }

  Future<void> markAsPending() async {
    completedAt = null;
    await supabase.from("tasks").update({"completed_at": null}).eq("id", id);
  }

  Future<void> updateReminder(String? newReminder) async {
    reminder = newReminder;
    await supabase.from("tasks").update({"reminder": newReminder}).eq("id", id);
  }

  Future<void> delete() async {
    await supabase.from("tasks").delete().eq("id", id);
  }

  Future<void> save() async {
    await supabase.from("tasks").upsert({
      "id": id,
      "title": title,
      "completed": completedAt,
      "reminder": reminder,
    });
  }
}

class TaskManager {
  static Future<Task?> createTask(String title) async {
    final data = await supabase.from("tasks").insert(
        {"title": title, "completed_at": null, "reminder": null}).select();

    if (data.isEmpty) {
      log("Error creating task");
      return null;
    }

    final task = Task.fromRowData(data[0]);
    return task;
  }

  static Future<List<Task>> fetchAllTasks() async {
    log("Fetching all tasks");
    final data = await supabase.from("tasks").select();

    return data.map((row) => Task.fromRowData(row)).toList();
  }
}

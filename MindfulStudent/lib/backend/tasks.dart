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
    final DateTime? completedAt = row["completed_at"];
    final String? reminder = row["reminder"];

    return Task(id, title, completedAt, reminder);
  }

  bool get completed {
    // TODO: adjust based on last completion time
    return completedAt != null;
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

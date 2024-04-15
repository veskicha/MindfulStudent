import 'dart:developer';

import 'package:mindfulstudent/main.dart';

class Task {
  final int id;
  final String title;
  bool completed;
  String reminder;

  Task(this.id, this.title, this.completed, this.reminder);

  static Task fromRowData(Map<String, dynamic> row) {
    final int id = row["id"];
    final String title = row["title"];
    final bool completed = row["completed"];
    final String reminder = row["reminder"];

    return Task(id, title, completed, reminder);
  }

  Future<void> markAsCompleted() async {
    completed = true;
    await supabase.from("tasks").update({"completed": true}).eq("id", id);
  }

  Future<void> markAsPending() async {
    completed = false;
    await supabase.from("tasks").update({"completed": false}).eq("id", id);
  }

  Future<void> updateReminder(String newReminder) async {
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
      "completed": completed,
      "reminder": reminder,
    });
  }
}

class TaskManager {
  static Future<Task?> createTask(String title) async {
    final res = await supabase
        .from("tasks")
        .insert({"title": title, "completed": false, "reminder": "None"});

    if (res.error != null) {
      // Handle error
      print("Error creating task: ${res.error?.message}");
      return null;
    }

    final List<Map<String, dynamic>>? data = res as List<Map<String, dynamic>>;
    if (data == null || data.isEmpty) return null;

    final task = Task.fromRowData(data[0]);
    return task;
  }

  static Future<List<Task>> fetchAllTasks() async {
    log("Fetching all tasks");
    final res = await supabase.from("tasks").select();

    if (res.isEmpty || res == null) {
      // Handle error
      print("Error fetching tasks: Result is empty or null");
      return [];
    }

    final List<Map<String, dynamic>>? data = res as List<Map<String, dynamic>>;
    if (data == null) return [];

    return data.map((row) => Task.fromRowData(row)).toList();
  }
}

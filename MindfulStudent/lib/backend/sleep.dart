import 'dart:developer';

import 'package:mindfulstudent/constants.dart';
import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SleepSession {
  final DateTime startTime;
  final DateTime endTime;

  const SleepSession({required this.startTime, required this.endTime});
}

class SleepData {
  final List<SleepSession> _sessions = [];

  void addSession(SleepSession session) {
    _sessions.add(session);
  }

  List<SleepSession> get sessions {
    return _sessions.toList()
      ..sort((SleepSession a, SleepSession b) =>
          a.startTime.compareTo(b.startTime));
  }
}

class SleepTracker {
  static const String _functionName = 'sleep-tracking';

  static const String loginUrl =
      '$supabaseUrl/functions/v1/$_functionName/login';
  static const String callbackUrl =
      '$supabaseUrl/functions/v1/$_functionName-callback/';

  static Future<SleepData?> getData() async {
    log("Updating sleep data");

    late final FunctionResponse res;
    try {
      res = await supabase.functions.invoke('$_functionName/logs');
      if (res.status != 200) return null;
    } on FunctionException catch (e) {
      log('Sleep tracking fetch error: ${e.reasonPhrase ?? ""}');
      return null;
    }

    final data = SleepData();
    for (final sessionData in res.data) {
      final startTime = DateTime.parse(sessionData["startTime"]);
      final endTime = DateTime.parse(sessionData["endTime"]);

      final session = SleepSession(startTime: startTime, endTime: endTime);

      data.addSession(session);
    }

    return data;
  }
}

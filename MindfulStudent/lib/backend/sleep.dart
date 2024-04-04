import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/constants.dart';
import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SleepSession {
  final DateTime startTime;
  final DateTime endTime;

  const SleepSession({required this.startTime, required this.endTime});
}

class SleepData {
  // For bedtime calculations
  static const int _targetSleepTime = 8 * 60 * 60 * 1000; // 8 hrs
  static const int _accuracy = 30 * 60 * 1000; // 30 mins

  final List<SleepSession> _sessions = [];

  void addSession(SleepSession session) {
    _sessions.add(session);
  }

  List<SleepSession> get sessions {
    return _sessions.toList()
      ..sort((SleepSession a, SleepSession b) =>
          a.startTime.compareTo(b.startTime));
  }

  (TimeOfDay, TimeOfDay) get optimalBedtime {
    final avgWakeEpoch = sessions
            .map((s) => s.endTime
                .copyWith(year: 1970, month: 1, day: 1)
                .millisecondsSinceEpoch)
            .fold(0, (a, b) => a + b) ~/
        sessions.length;

    // Round to next `accuracy`
    final targetEpochUpper = DateTime.fromMillisecondsSinceEpoch(
        (avgWakeEpoch - _targetSleepTime) ~/ _accuracy * _accuracy + _accuracy);
    final targetEpochLower = DateTime.fromMillisecondsSinceEpoch(
        targetEpochUpper.millisecondsSinceEpoch - (1 * 60 * 60 * 1000));

    return (
      TimeOfDay.fromDateTime(targetEpochLower),
      TimeOfDay.fromDateTime(targetEpochUpper)
    );
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
      log(e.details.toString());
      return null;
    }

    final data = SleepData();
    for (final sessionData in res.data) {
      final startTime = DateTime.parse(sessionData["startTime"]).toLocal();
      final endTime = DateTime.parse(sessionData["endTime"]).toLocal();

      final session = SleepSession(startTime: startTime, endTime: endTime);

      data.addSession(session);
    }

    return data;
  }
}

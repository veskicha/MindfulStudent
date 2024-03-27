import 'dart:developer';

import 'package:mindfulstudent/constants.dart';
import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SleepSession {}

class SleepData {}

class SleepTracker {
  static const String _functionName = 'sleep-tracking';

  static const String loginUrl =
      '$supabaseUrl/functions/v1/$_functionName/login';
  static const String callbackUrl =
      '$supabaseUrl/functions/v1/$_functionName-callback/';

  static Future<SleepData?> getData() async {
    late final FunctionResponse res;
    try {
      res = await supabase.functions.invoke('$_functionName/logs');
      if (res.status != 200) return null;
    } on FunctionException catch (e) {
      log('Sleep tracking fetch error: ${e.reasonPhrase ?? ""}');
      return null;
    }

    log(res.data.toString());

    return null;
  }
}

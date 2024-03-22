import 'dart:developer';

import 'package:mindfulstudent/main.dart';

class Auth {
  static bool get isLoggedIn {
    return supabase.auth.currentSession != null;
  }

  static Future<bool> login(String email, String password) async {
    log("Attempt login for $email");
    await supabase.auth.signInWithPassword(email: email, password: password);
    return true;
  }

  static Future<bool> signup(String email, String name, String password) async {
    log("Create new account: $email");
    final res = await supabase.auth
        .signUp(email: email, password: password, data: {"name": name});
    return res.session != null;
  }
}

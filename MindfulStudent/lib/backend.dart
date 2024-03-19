import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class Backend {
  static Future<bool> initialize(String url, String anonKey) async {
    await Supabase.initialize(url: url, anonKey: anonKey);

    await for (final evt in client.auth.onAuthStateChange) {
      switch (evt.event) {
        case AuthChangeEvent.initialSession:
          return false;

        default:
          return true;
      }
    }

    return false;
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }

  static bool get isLoggedIn {
    return Backend.client.auth.currentSession != null;
  }

  static Future<bool> login(String email, String password) async {
    log("Attempt login for $email");
    late final AuthResponse resp;
    try {
      resp = await client.auth
          .signInWithPassword(email: email, password: password);
    } on AuthException catch (_) {
      return false;
    }

    log("Login response user: $resp");
    return resp.user != null;
  }
}

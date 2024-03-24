import 'dart:developer';

import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  static final Map<String, Profile> _cache = {};

  final String id;
  String? name;

  Profile(this.id, this.name);

  static Future<Profile?> get(String id) async {
    final cachedProfile = _cache[id];
    if (cachedProfile != null) return cachedProfile;

    late final Map<String, dynamic> data;
    try {
      final rows = await supabase.from("profiles").select().eq("id", id);
      if (rows.isEmpty) return null;
      data = rows[0];
    } catch (e) {
      log(e.toString());
      return null;
    }

    _cache[id] = Profile(data["id"], data["name"]);
    return _cache[id];
  }
}

class Auth {
  static bool get isLoggedIn {
    return supabase.auth.currentSession != null;
  }

  static User? get user {
    return supabase.auth.currentUser;
  }

  static Future<bool> login(String email, String password) async {
    log("Attempt login for $email");
    await supabase.auth.signInWithPassword(email: email, password: password);
    return true;
  }

  static Future<bool> signUp(String email, String name, String password) async {
    log("Create new account: $email");
    final res = await supabase.auth
        .signUp(email: email, password: password, data: {"name": name});
    return res.session != null;
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static Future<Profile?> getProfile() async {
    final user = Auth.user;
    if (user == null) return null;
    return Profile.get(user.id);
  }
}

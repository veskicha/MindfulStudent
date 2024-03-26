import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart' as constants;
import '/main.dart';

class Profile {
  final String id;
  String? name;
  String? avatarUrl;

  Profile({required this.id, required this.name, required this.avatarUrl});

  static Future<Profile?> get(String id) async {
    late final Map<String, dynamic> data;
    try {
      final rows = await supabase.from("profiles").select().eq("id", id);
      if (rows.isEmpty) return null;
      data = rows[0];
    } catch (e) {
      log(e.toString());
      return null;
    }

    return Profile(
        id: data["id"], name: data["name"], avatarUrl: data["avatarUrl"]);
  }
}

class Auth {
  static Future<void> init() async {
    await Supabase.initialize(
        url: constants.supabaseUrl, anonKey: constants.supabaseAnonKey);

    supabase.auth.onAuthStateChange.listen((data) {
      log(data.event.toString());
      switch (data.event) {
        case (AuthChangeEvent.initialSession):
        case (AuthChangeEvent.signedIn):
          if (isLoggedIn) profileProvider.updateProfile();
          break;
        case (AuthChangeEvent.signedOut):
          profileProvider.setProfile(null);
          break;
        default:
      }
    });
  }

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

  static Future<bool> updateUser(UserAttributes attrs) async {
    await supabase.auth.updateUser(attrs);
    return true;
  }

  static Future<Profile?> getProfile() async {
    final user = Auth.user;
    if (user == null) return null;

    final profile = await Profile.get(user.id);
    return profile;
  }

  static Future<Profile?> updateProfile(Profile profile) async {
    final id = Auth.user?.id;
    if (id == null) return null;

    await supabase.from("profiles").update({"name": profile.name}).eq("id", id);

    final newProfile = await getProfile();
    profileProvider.setProfile(newProfile);
    return newProfile;
  }
}

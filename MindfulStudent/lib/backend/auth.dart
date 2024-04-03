import 'dart:developer';

import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  String? name;
  String? avatarUrl;
  String? fcm_token;

  Profile({required this.id, required this.name, required this.avatarUrl , required this.fcm_token});

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
        id: data["id"], name: data["name"], avatarUrl: data["avatarUrl"] , fcm_token: data["fcm_token"]);
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

    // Don't wait for this future to complete - handled by provider
    getProfile();

    return true;
  }

  static Future<bool> signUp(String email, String name, String password) async {
    log("Create new account: $email");
    final res = await supabase.auth
        .signUp(email: email, password: password, data: {"name": name});
    final ok = res.session != null;

    // Don't await this
    if (ok) getProfile();

    return ok;
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();

    profileProvider.updateProfile(null);
  }

  static Future<bool> updateUser(UserAttributes attrs) async {
    await supabase.auth.updateUser(attrs);
    return true;
  }

  static Future<Profile?> getProfile() async {
    final user = Auth.user;
    if (user == null) return null;

    final profile = await Profile.get(user.id);
    profileProvider.updateProfile(profile);
    return profile;
  }

  static Future<Profile?> updateProfile(Profile profile) async {
    final id = Auth.user?.id;
    if (id == null) {
      print("here here " + "ASd");
      return null;
    }


    await supabase.from("profiles").update({"name": profile.name}).eq("id", id);
    // This will also trigger the provider to update
    return await getProfile();
  }

}

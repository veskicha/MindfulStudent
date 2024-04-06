import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/firebase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart' as constants;
import '/main.dart';

class Profile {
  final String id;
  String? name;
  String? avatarUrl;
  String? fcmToken;

  Profile(
      {required this.id,
      required this.name,
      required this.avatarUrl,
      required this.fcmToken});

  @override
  String toString() {
    return "Profile(name: '$name')";
  }

  NetworkImage? getAvatarImage() {
    final url = avatarUrl;
    if (url == null || url.isEmpty) return null;
    return NetworkImage(url);
  }

  static Profile fromRowData(Map<String, dynamic> row) {
    return Profile(
      id: row["id"],
      name: row["name"],
      avatarUrl: row["avatarUrl"],
      fcmToken: row["fcm_token"],
    );
  }

  static Future<Profile?> get(String id) async {
    log("Getting profile for $id");

    late final List<Map<String, dynamic>> data;
    try {
      data = await supabase.from("profiles").select().eq("id", id);
    } catch (e) {
      log(e.toString());
      return null;
    }

    final row = data.firstOrNull;
    return row == null ? null : Profile.fromRowData(row);
  }

  static Future<List<Profile>> find(String name) async {
    late final List<Map<String, dynamic>> data;
    try {
      data = await supabase
          .from("profiles")
          .select()
          .neq("role", "HEALTH_EXPERT")
          .ilike("name", "%$name%");
    } catch (e) {
      log(e.toString());
      data = [];
    }

    return data.map((row) => Profile.fromRowData(row)).toList();
  }

  static Future<List<Profile>> getHealthExperts() async {
    late final List<Map<String, dynamic>> data;
    try {
      data =
          await supabase.from("profiles").select().eq("role", "HEALTH_EXPERT");
    } catch (e) {
      log(e.toString());
      data = [];
    }

    return data.map((row) => Profile.fromRowData(row)).toList();
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
          if (isLoggedIn) {
            // note the order of initialization here
            profileProvider.updateProfile().then((_) {
              Firebase.init();
              chatProvider.init();
            });
            sleepDataProvider.updateData();
          }
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

  static String? get jwt {
    return supabase.auth.currentSession?.accessToken;
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

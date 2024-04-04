import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';

class UserProfileProvider with ChangeNotifier {
  Profile? _userProfile;

  Profile? get userProfile => _userProfile;

  void setProfile(Profile? newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }

  Future<void> updateProfile() async {
    final profile = await Auth.getProfile();
    setProfile(profile);
  }
}

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';

// Create a ChangeNotifier for managing the user profile data
class UserProfileProvider with ChangeNotifier {
  // Initialize user profile data
  Profile? _userProfile;

  // Getter for user profile data
  Profile? get userProfile => _userProfile;

  // Method to update user profile data
  void updateProfile(Profile? newProfile) {
    _userProfile = newProfile;
    notifyListeners(); // Notify listeners of the change
  }
}

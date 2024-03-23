import 'package:flutter/material.dart';

// Define a model class to represent the user profile data
class UserProfile {
  final String name;
  final int age;
  final String location;
  final String imageUrl;

  UserProfile({
    required this.name,
    required this.age,
    required this.location,
    required this.imageUrl,
  });
}

// Create a ChangeNotifier for managing the user profile data
class UserProfileProvider with ChangeNotifier {
  // Initialize user profile data
  UserProfile _userProfile = UserProfile(
    name: 'Name Surname',
    age: 22,
    location: 'Enschede, Netherlands',
    imageUrl: 'assets/profile_image.png', // Path to default profile image
  );

  // Getter for user profile data
  UserProfile get userProfile => _userProfile;

  // Method to update user profile data
  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners(); // Notify listeners of the change
  }
}

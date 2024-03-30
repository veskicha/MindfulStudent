import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/screens/home/profile_edit_screen.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'dart:io';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  String? _avatarUrl;
  int _selectedIndex = 3; // Default selected index

  @override
  void initState() {
    super.initState();
    final profile = profileProvider.userProfile;
    final user = Auth.user;
    if (profile == null || user == null) return;
    _avatarUrl = profile.avatarUrl;
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  ImageProvider<Object>? getAvatarImage() {
    _avatarUrl = profileProvider.userProfile!.avatarUrl;
    if (_avatarUrl != null) {
      return NetworkImage(_avatarUrl!); // Using NetworkImage for _avatarUrl
    }
    return null; // Return null if both are unavailable
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/background.jpg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                const Positioned(
                  top: 40,
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:60, vertical: 0),
            child: Consumer<UserProfileProvider>(
              builder: (context, profileProvider, child) {
                Profile? userProfile = profileProvider.userProfile;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Container(
                        padding: const EdgeInsets.all(2), // Border width
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFC8D4D6), // Border color
                        ),
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: _avatarUrl != null ? getAvatarImage() : null,
                          backgroundColor: _avatarUrl == null ? Color(0xFF497077) : null,
                          child: _avatarUrl == null
                              ? Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userProfile?.name ?? "Unknown User",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF497077),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.only(bottom: 40),
                    ),
                    Button('Edit profile', onPressed: () async {
                      // Navigate to EditProfilePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()),
                      );
                    }),
                    const SizedBox(height: 10),
                    Button('Sign out', onPressed: () async {
                      return Auth.signOut().then((_) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      });
                    })
                  ],
                );
              },
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

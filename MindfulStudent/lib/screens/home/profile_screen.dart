import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/screens/home/profile_edit_screen.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:mindfulstudent/widgets/profile_img.dart';
import 'package:provider/provider.dart';

import '../../widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Default selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8D4D6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                const Positioned(
                  top: 80,
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF497077),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
            child: Consumer<UserProfileProvider>(
              builder: (context, profileProvider, child) {
                final Profile? userProfile = profileProvider.userProfile;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2), // Border width
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFC8D4D6), // Border color
                      ),
                      child: ProfilePicture(
                        profile: userProfile,
                        radius: 100,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      userProfile?.name ?? "Unknown User",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF497077),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                    ),
                    Button('Edit profile', onPressed: () async {
                      // Navigate to EditProfilePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Button('Sign out', onPressed: () async {
                      return Auth.signOut().then((_) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
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

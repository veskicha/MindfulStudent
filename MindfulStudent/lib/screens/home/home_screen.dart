import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class FeatureBlock extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const FeatureBlock({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFC8D4D6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final double _progress = 0.7;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                color: const Color(0xFFC8D4D6),
                width: double.infinity,
                height: 220,
                child: Consumer<UserProfileProvider>(
                    builder: (context, profileProvider, child) {
                  final Profile? userProfile = profileProvider.userProfile;
                  final avatarImg = userProfile?.getAvatarImage();

                  return Stack(
                    children: [
                      Positioned(
                        top: 88,
                        left: 30,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: avatarImg,
                          backgroundColor: avatarImg == null
                              ? const Color(0xFF497077)
                              : null,
                          child: avatarImg == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 100,
                        child: Text(
                          userProfile == null
                              ? 'Welcome!'
                              : 'Welcome, ${userProfile.name}!',
                          style: const TextStyle(
                            color: Color(0xFF497077),
                            fontFamily: 'Poppins',
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  );
                })),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Progress',
                    style: TextStyle(
                      color: Color(0xFF497077),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        child: LinearProgressIndicator(
                          backgroundColor: const Color(0xFFE5E5E5),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5C7F85)),
                          value: _progress,
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // Disable GridView scrolling
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      FeatureBlock(
                        title: 'Chat',
                        imagePath: 'assets/Chat.png',
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/chat');
                        },
                      ),
                      FeatureBlock(
                        title: 'Journal',
                        imagePath: 'assets/Journal.png',
                        onTap: () {
                          // Handle navigation to feature Journal page
                        },
                      ),
                      FeatureBlock(
                        title: 'Sleep',
                        imagePath: 'assets/Sleep.png',
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/sleep');
                        },
                      ),
                      FeatureBlock(
                        title: 'Goals',
                        imagePath: 'assets/Goals.png',
                        onTap: () {
                          // Handle navigation to Goals page
                        },
                      ),
                      FeatureBlock(
                        title: 'Breathing Exercise',
                        imagePath: 'assets/Goals.png',
                        onTap: () {
                          // Handle navigation to Breathing excercise page
                        },
                      ),
                      FeatureBlock(
                        title: 'Books',
                        imagePath: 'assets/Journal.png',
                        onTap: () {
                          // Handle navigation to Books page
                        },
                      ),
                      FeatureBlock(
                        title: 'Emergency Contact',
                        imagePath: 'assets/Chat.png',
                        onTap: () {
                          // Handle navigation to Emergency Contact page
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ), // Using the BottomNavBar widget
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

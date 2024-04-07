import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:mindfulstudent/screens/home/journal_screen.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

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
          color: const Color(0xB35C7F85),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color with some opacity
              offset: const Offset(0, 3), // Horizontal and vertical offset of shadow
              blurRadius: 5, // Blur effect
              spreadRadius: 2, // Spread effect
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0, bottom: 0.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 50,
                      width: 50,
                      color: const Color(0xFF497077),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.only(top: 6.0, left: 0.0, right: 0.0, bottom: 0.0),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white, // Text color
                      fontWeight: FontWeight.bold, // Bold text
                      fontSize: 25,
                    ),
                  ),

                ],
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // If already loaded we should just skip all of this
    if (profileProvider.userProfile != null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    profileProvider.addListener(_onProfileLoaded);
  }

  @override
  void dispose() {
    super.dispose();

    profileProvider.removeListener(_onProfileLoaded);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onProfileLoaded() {
    if (profileProvider.userProfile == null) return;

    Future.delayed(const Duration(seconds: 1)).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: SpinKitSquareCircle(
            color: Color(0xFF497077),
            size: 50.0,
          ),
        ),
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFC8D4D6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
                width: double.infinity,
                height: 220,
                child: Consumer<UserProfileProvider>(
                    builder: (context, profileProvider, child) {
                  final Profile? userProfile = profileProvider.userProfile;
                  final url = profileProvider.userProfile?.avatarUrl;

                  return Stack(
                    children: [
                      Positioned(
                        top: 82,
                        left: 30,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/load.gif',
                              image: url ?? 'assets/load.gif',
                              fit: BoxFit.cover,
                              width: 80.0,  // Ensure this matches the radius of CircleAvatar
                              height: 80.0, // Ensure this matches the radius of CircleAvatar
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeOutDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 105,
                        left: 120,
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
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0, bottom: 10.0),
                    child: Text(
                      'Daily Task Progress',
                      style: TextStyle(
                        color: Color(0xFF497077),
                        fontSize: 18, // Text size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: const Color(0xFFE5E5E5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C7F85)),
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
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0, bottom: 50.0),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1.0,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      FeatureBlock(
                        title: 'Chat',
                        imagePath: 'assets/Chat.png',
                        onTap: () {
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const ChatScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var screenWidth = MediaQuery.of(context).size.width;
                              var screenHeight = MediaQuery.of(context).size.height;

                              // Example coordinates (x, y)
                              var x = 100.0; // Replace with your X coordinate
                              var y = 500.0; // Replace with your Y coordinate

                              // Calculate alignment based on x and y
                              var alignmentX = (x - screenWidth / 2) / (screenWidth / 2);
                              var alignmentY = (y - screenHeight / 2) / (screenHeight / 2);
                              var customAlignment = Alignment(alignmentX, alignmentY);

                              var scaleTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));

                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: scaleTween.evaluate(animation),
                                    alignment: customAlignment, // Custom alignment based on x, y
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ));
                        },
                      ),



                      FeatureBlock(
                        title: 'Journal',
                        imagePath: 'assets/Journal.png',
                        onTap: () {
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const JournalScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var screenWidth = MediaQuery.of(context).size.width;
                              var screenHeight = MediaQuery.of(context).size.height;

                              // Example coordinates (x, y)
                              var x = 300.0; // Replace with your X coordinate
                              var y = 500.0; // Replace with your Y coordinate

                              // Calculate alignment based on x and y
                              var alignmentX = (x - screenWidth / 2) / (screenWidth / 2);
                              var alignmentY = (y - screenHeight / 2) / (screenHeight / 2);
                              var customAlignment = Alignment(alignmentX, alignmentY);

                              var scaleTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));

                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: scaleTween.evaluate(animation),
                                    alignment: customAlignment, // Custom alignment based on x, y
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ));
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
                        title: 'Breathing\nExercise',
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
                        title: 'Emergency\nContact',
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
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/provider/task_provider.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:mindfulstudent/screens/home/journal_screen.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:mindfulstudent/widgets/profile_img.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class FeatureBlock extends StatelessWidget {
  final String title;
  final IconData iconData; // Changed from imagePath to iconData
  final VoidCallback onTap;

  const FeatureBlock({
    super.key,
    required this.title,
    required this.iconData, // Changed parameter
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
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 3),
              blurRadius: 5,
              spreadRadius: 2,
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
                    padding: EdgeInsets.only(
                        top: 5.0, left: 0.0, right: 0.0, bottom: 0.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      // Adjust padding as needed
                      child: Icon(
                        iconData,
                        size: 27,
                        color: const Color(0xFF497077),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

                  return Stack(
                    children: [
                      Positioned(
                        top: 82,
                        left: 30,
                        child: ProfilePicture(
                          profile: userProfile,
                          radius: 40,
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
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<TaskProvider>(
                      builder: (context, taskProvider, child) {
                    final tasks = taskProvider.tasks;
                    if (tasks.isEmpty) return const Column();

                    final progress =
                        taskProvider.completedTasks.length / tasks.length;

                    return Column(children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 15.0, left: 8.0, right: 8.0, bottom: 10.0),
                        child: Text(
                          'Task Progress',
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
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF5C7F85)),
                                  value: progress,
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(progress * 100).toInt()}%',
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
                        padding: EdgeInsets.only(
                            top: 0.0, left: 0.0, right: 0.0, bottom: 50.0),
                      ),
                      Container(
                        width: double.infinity,
                        height: 1.0,
                        color: Colors.grey[300],
                      ),
                    ]);
                  }),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      FeatureBlock(
                        title: 'Chat',
                        iconData: Icons.chat,
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ChatPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var screenWidth =
                                      MediaQuery.of(context).size.width;
                                  var screenHeight =
                                      MediaQuery.of(context).size.height;

                                  // Example coordinates (x, y)
                                  var x =
                                      100.0; // Replace with your X coordinate
                                  var y =
                                      500.0; // Replace with your Y coordinate

                                  // Calculate alignment based on x and y
                                  var alignmentX =
                                      (x - screenWidth / 2) / (screenWidth / 2);
                                  var alignmentY = (y - screenHeight / 2) /
                                      (screenHeight / 2);
                                  var customAlignment =
                                      Alignment(alignmentX, alignmentY);

                                  var scaleTween =
                                      Tween<double>(begin: 0.0, end: 1.0).chain(
                                          CurveTween(curve: Curves.easeInOut));

                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: scaleTween.evaluate(animation),
                                        alignment: customAlignment,
                                        // Custom alignment based on x, y
                                        child: child,
                                      );
                                    },
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ));
                        },
                      ),
                      FeatureBlock(
                        title: 'Journal',
                        iconData: Icons.book,
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const JournalScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var screenWidth =
                                      MediaQuery.of(context).size.width;
                                  var screenHeight =
                                      MediaQuery.of(context).size.height;

                                  // Example coordinates (x, y)
                                  var x =
                                      300.0; // Replace with your X coordinate
                                  var y =
                                      500.0; // Replace with your Y coordinate

                                  // Calculate alignment based on x and y
                                  var alignmentX =
                                      (x - screenWidth / 2) / (screenWidth / 2);
                                  var alignmentY = (y - screenHeight / 2) /
                                      (screenHeight / 2);
                                  var customAlignment =
                                      Alignment(alignmentX, alignmentY);

                                  var scaleTween =
                                      Tween<double>(begin: 0.0, end: 1.0).chain(
                                          CurveTween(curve: Curves.easeInOut));

                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: scaleTween.evaluate(animation),
                                        alignment: customAlignment,
                                        // Custom alignment based on x, y
                                        child: child,
                                      );
                                    },
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ));
                        },
                      ),
                      FeatureBlock(
                        title: 'Sleep',
                        iconData: Icons.nights_stay,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/sleep');
                        },
                      ),
                      FeatureBlock(
                        title: 'Breathing\nExercise',
                        iconData: Icons.air,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/breath');
                          // Handle navigation to Breathing excercise page
                        },
                      ),
                      FeatureBlock(
                        title: 'My Tasks',
                        iconData: Icons.task,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/tasks');
                        },
                      ),
                      FeatureBlock(
                        title: 'Emergency\nContact',
                        iconData: Icons.contact_emergency,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/emergency');
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

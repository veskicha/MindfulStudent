import 'package:flutter/material.dart';

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
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

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
              child: const Stack(
                children: [
                  Positioned(
                    top: 100,
                    left: 40,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/Profile.png'),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 100,
                    child: Text(
                      'Good morning, Mike',
                      style: TextStyle(
                        color: Color(0xFF497077),
                        fontFamily: 'Poppins',
                        fontSize: 25,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                          // Handle navigation to feature chat page
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
                          // Handle navigation to Sleep page
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF5C7F85),
        selectedItemColor: const Color(0xFF5C7F85),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/HomeIcon.png'),
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/Sleep.png'),
              size: 24,
            ),
            label: 'Sleep',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/Chat.png'),
              size: 24,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/Profile.png'),
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

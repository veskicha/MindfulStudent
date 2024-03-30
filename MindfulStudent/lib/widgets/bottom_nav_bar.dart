import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 74,
          color: Colors.transparent,
        ), // To ensure enough space is available for the bar
        Positioned(
          bottom: 15, // 5 units from the bottom
          child: Container(
            width: MediaQuery.of(context).size.width * 0.96, // 80% of screen width
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BottomNavigationBar(
                backgroundColor: const Color(0xFF5C7F85),
                selectedItemColor: const Color(0xFF5C7F85),
                unselectedItemColor: Colors.black,
                currentIndex: selectedIndex,
                onTap: (index) {
                  onItemTapped(index); // Invoke the callback provided
                  // Optionally handle navigation inside here
                  switch (index) {
                    case 0:
                    // Navigate to Home
                      Navigator.pushReplacementNamed(context, '/home');
                      break;
                    case 1:
                    // Navigate to Sleep
                      Navigator.pushReplacementNamed(context, '/sleep');
                      break;
                    case 2:
                    // Navigate to Chat
                      Navigator.pushReplacementNamed(context, '/chat');
                      break;
                    case 3:
                    // Navigate to Profile
                      Navigator.pushReplacementNamed(context, '/profile');
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/HomeIcon.png'), size: 24),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/Sleep.png'), size: 24),
                    label: 'Sleep',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/Chat.png'), size: 24),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/Profile.png'), size: 24),
                    label: 'Profile',
                  ),
                ],
                showSelectedLabels: false,
                showUnselectedLabels: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF5C7F85),
      selectedItemColor: const Color(0xFF5C7F85),
      unselectedItemColor: Colors.black,
      currentIndex: selectedIndex,
      onTap: (index) {
        // Call the onItemTapped function provided by the parent widget
        onItemTapped(index);
        // Navigate to the respective page based on the index
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/sleep');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/chat');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          default:
            break;
        }
      },
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
    );
  }
}

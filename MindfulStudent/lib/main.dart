import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindfulstudent/chat_screen.dart';
import 'package:mindfulstudent/home_screen.dart';
import 'package:mindfulstudent/profile_screen.dart';
import 'splash_screen.dart'; // Import your splash_screen.dart file
import 'package:mindfulstudent/provider/user_profile_provider.dart' as Provider;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          Provider.UserProfileProvider(), // Initialize UserProfileProvider
      child: MaterialApp(
        home: SplashScreen(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/chat': (context) => ChatPage(),
          '/sleep': (context) => HomeScreen(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}

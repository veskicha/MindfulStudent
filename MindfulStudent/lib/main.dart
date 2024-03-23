import 'package:flutter/material.dart';
import 'package:mindfulstudent/sleep_tracking.dart';
import 'package:provider/provider.dart';
import 'package:mindfulstudent/chat_screen.dart';
import 'package:mindfulstudent/home_screen.dart';
import 'package:mindfulstudent/profile_screen.dart';
import 'splash_screen.dart'; // Import your splash_screen.dart file
import 'package:mindfulstudent/provider/user_profile_provider.dart' as Provider;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart' as constants;
import 'screens/home/splash_screen.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: constants.supabaseUrl, anonKey: constants.supabaseAnonKey);

  runApp(const MaterialApp(
    home: SplashScreen(),
));

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
          '/sleep': (context) => SleepTrackingPage(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}

final supabase = Supabase.instance.client;

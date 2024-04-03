import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart' as constants;
import 'provider/user_profile_provider.dart';
import 'screens/home/chat_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/home/sleep_tracking_page.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
      url: constants.supabaseUrl, anonKey: constants.supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: profileProvider,
      child: MaterialApp(
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/chat': (context) => const ChatPage(),
          '/sleep': (context) => const SleepTrackingPage(),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}

final supabase = Supabase.instance.client;
final profileProvider = UserProfileProvider();

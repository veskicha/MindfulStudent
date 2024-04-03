import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend/auth.dart';
import 'firebase_options.dart';
import 'provider/sleep_data_provider.dart';
import 'provider/user_profile_provider.dart';
import 'screens/home/chat_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/home/sleep_tracking_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Auth.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: sleepDataProvider),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final supabase = Supabase.instance.client;

final profileProvider = UserProfileProvider();
final sleepDataProvider = SleepDataProvider();

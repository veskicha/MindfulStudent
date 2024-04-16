import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindfulstudent/provider/chat_provider.dart';
import 'package:mindfulstudent/screens/home/breath_screen.dart';
import 'package:mindfulstudent/screens/home/task_tracking.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend/auth.dart';
import 'firebase_options.dart';
import 'provider/sleep_data_provider.dart';
import 'provider/task_provider.dart';
import 'provider/user_profile_provider.dart';
import 'screens/home/chat_screen.dart';
import 'screens/home/emergency_contact.dart';
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
        ChangeNotifierProvider.value(value: chatProvider),
        ChangeNotifierProvider.value(value: taskProvider),
      ],
      child: MaterialApp(

        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/chat': (context) => const ChatPage(),
          '/sleep': (context) => const SleepTrackingPage(),
          '/profile': (context) => const ProfilePage(),
          '/tasks': (context) => const TaskTrackingPage(),
          '/breath': (context) => const BreathingExercisePage(),
          '/emergency': (context) => const EmergencyContactPage()
        },
        theme: ThemeData(
          primaryColor: const Color(0xFF497077),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: const Color(0xFF497077).withOpacity(0.3),
            selectionHandleColor: const Color(0xFF497077),
            cursorColor: const Color(0xFF497077),
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final supabase = Supabase.instance.client;

final profileProvider = UserProfileProvider();
final sleepDataProvider = SleepDataProvider();
final chatProvider = ChatProvider();
final taskProvider = TaskProvider();

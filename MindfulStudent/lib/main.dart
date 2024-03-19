import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/screens/home/home_screen.dart';

import 'backend.dart';
import 'constants.dart' as constants;
import 'screens/home/splash_screen.dart';

Future<void> main() async {
  final isLoggedIn = await Backend.initialize(
      constants.supabaseUrl, constants.supabaseAnonKey);
  log("Supabase init done, logged in? > $isLoggedIn");

  final initScreen = isLoggedIn ? const HomeScreen() : const SplashScreen();

  runApp(MaterialApp(
    home: initScreen,
  ));
}

import 'package:flutter/material.dart';

import 'backend.dart';
import 'constants.dart' as constants;
import 'screens/home/splash_screen.dart';

void main() {
  Backend.initialize(constants.supabaseUrl, constants.supabaseAnonKey);

  runApp(const MaterialApp(
    home: SplashScreen(),
  ));
}

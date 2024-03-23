import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart' as constants;
import 'screens/home/splash_screen.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: constants.supabaseUrl, anonKey: constants.supabaseAnonKey);

  runApp(const MaterialApp(
    home: SplashScreen(),
  ));
}

final supabase = Supabase.instance.client;

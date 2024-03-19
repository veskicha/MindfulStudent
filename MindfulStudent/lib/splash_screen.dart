import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the login screen when tapped
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ScreenLogin()),
        );
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/Logophotoroom1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to MindfulStudent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(73, 112, 119, 0.89),
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap anywhere to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(73, 112, 119, 0.89),
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

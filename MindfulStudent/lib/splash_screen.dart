import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the login screen when tapped
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScreenLogin()),
        );
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/Logophotoroom1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
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
              SizedBox(height: 10),
              Text(
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

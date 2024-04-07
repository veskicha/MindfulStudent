import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/screens/auth/signup_screen.dart';
import 'package:mindfulstudent/screens/home/home_screen.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:mindfulstudent/widgets/text_line_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextLineField _emailField = TextLineField("Email address");
  final TextLineField _passwordField = TextLineField(
    "Password",
    obscureText: true,
  );

  Future<void> login() {
    final email = _emailField.getText();
    final password = _passwordField.getText();

    return Auth.login(email, password).then((_) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }).catchError((e) {
      if (e is AuthException) {
        showError(context, "Login error", description: e.message);
        return;
      }
      showError(context, "Unknown error", description: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF497077),
                  image: DecorationImage(
                    image: AssetImage("assets/Logophotoroom1.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF497077),
                  fontSize: 26,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 80),
              FractionallySizedBox(widthFactor: 0.8, child: _emailField),
              const SizedBox(height: 20),
              FractionallySizedBox(widthFactor: 0.8, child: _passwordField),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Forgot password action
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              FractionallySizedBox(
                widthFactor: 0.8, // Button width is 80% of screen width
                child: Button('Login', onPressed: login),
              ),
              const SizedBox(height: 40), // Space between button and line
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Line width is 80% of screen width
                  height: 1, // Line thickness
                  color: Colors.grey[300], // Line color
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: 'Don’t have an account? ',
                  style: const TextStyle(
                    color: Color(0xFF242424),
                    fontSize: 14,
                  ),
                  children: [
                    // Wrap "Sign Up" text in GestureDetector to navigate to sign-up screen
                    TextSpan(
                      text: 'Sign Up',
                      style: const TextStyle(
                          color: Color(0xFF497077),
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to the sign-up screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

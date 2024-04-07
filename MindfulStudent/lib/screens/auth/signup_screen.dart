import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/screens/home/home_screen.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:mindfulstudent/widgets/text_line_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextLineField _nameField = TextLineField("Your name");
  final TextLineField _emailField = TextLineField("Your email");
  final TextLineField _passwordField = TextLineField(
    "Password",
    obscureText: true,
  );
  final TextLineField _passwordConfirmField = TextLineField(
    "Repeat password",
    obscureText: true,
  );

  Future<void> signup() async {
    final name = _nameField.getText();
    final email = _emailField.getText();
    final password = _passwordField.getText();
    final passwordConfirm = _passwordConfirmField.getText();

    if (password != passwordConfirm) {
      showError(context, "Passwords do not match!");
      return;
    }

    return Auth.signUp(email, name, password).then((res) {
      if (!res) {
        showInfo(context, "Account created!",
            description: "Please check your email for a confirmation link.");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
        return;
      }

      showToast(context, "Account created!",
          description: "Welcome to MindfulStudent!",
          type: ToastificationType.success);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }).catchError((e) {
      if (e is AuthException) {
        showError(context, "Signup error", description: e.message);
        return;
      }
      showError(context, "Unknown error", description: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Image.asset(
                    'assets/Logophotoroom1.png', // Path to your image in assets
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width * 0.3,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF497077),
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  FractionallySizedBox(widthFactor: 0.8, child: _nameField),
                  const SizedBox(height: 20),
                  FractionallySizedBox(widthFactor: 0.8, child: _emailField),
                  const SizedBox(height: 20),
                  FractionallySizedBox(widthFactor: 0.8, child: _passwordField),
                  const SizedBox(height: 20),
                  FractionallySizedBox(
                      widthFactor: 0.8, child: _passwordConfirmField),
                  const SizedBox(height: 60),
                  FractionallySizedBox(
                    widthFactor: 0.8, // Button width is 80% of screen width
                    child: Button('Sign Up', onPressed: signup),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Line width is 80% of screen width
                      height: 1, // Line thickness
                      color: Colors.grey[300], // Line color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Color(0xFF242424),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate back to login screen
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF497077),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/screens/home/home_screen.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class TextLineField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final double? widthFactor;
  final double borderRadius;

  const TextLineField(
      this.hintText, {super.key,
        this.obscureText = false,
        required this.controller,
        this.widthFactor,
        this.borderRadius = 20.0,
      });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor ?? 1.0,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: const Color(0xFF497077),
        style: const TextStyle(
          color: Color(0xFF497077),
        ),
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFFC8D4D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xFFC8D4D6)),
          ),
        ),
      ),
    );
  }
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final passwordConfirm = passwordConfirmController.text;

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
    final nameField = TextLineField(
      "Your name",
      controller: nameController,
      widthFactor: 0.8,
      borderRadius: 20.0,
    );
    final emailField = TextLineField(
      "Your email",
      controller: emailController,
      widthFactor: 0.8,
      borderRadius: 20.0,
    );
    final passwordField = TextLineField(
      "Your password",
      obscureText: true,
      controller: passwordController,
      widthFactor: 0.8,
      borderRadius: 20.0,
    );
    final passwordConfirmField = TextLineField(
      "Confirm password",
      obscureText: true,
      controller: passwordConfirmController,
      widthFactor: 0.8,
      borderRadius: 20.0,
    );
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
                  nameField,
                  const SizedBox(height: 20),
                  emailField,
                  const SizedBox(height: 20),
                  passwordField,
                  const SizedBox(height: 20),
                  passwordConfirmField,
                  const SizedBox(height: 60),
                  FractionallySizedBox(
                    widthFactor: 0.8, // Button width is 80% of screen width
                    child: Button('Sign Up', onPressed: signup),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8, // Line width is 80% of screen width
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

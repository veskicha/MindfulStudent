import 'package:flutter/material.dart';
import 'package:mindfulstudent/widgets/text_line_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final TextLineField _nameField = TextLineField("Loading...");
  final TextLineField _emailField = TextLineField("Loading...");
  final TextLineField _passwordField = TextLineField("Loading...");

  @override
  void initState() {
    super.initState();

    _nameField.setText("Name Surname");
    _emailField.setText("namesurname@gmail.com");
    _passwordField.setText("*********");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFC8D4D6),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF497077),
              ),
            ),
            _nameField,
            const SizedBox(height: 16),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF497077),
              ),
            ),
            _emailField,
            const SizedBox(height: 16),
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF497077),
              ),
            ),
            _passwordField,
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to ProfilePage
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF497077),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

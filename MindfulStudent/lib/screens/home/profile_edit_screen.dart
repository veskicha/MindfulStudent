import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:mindfulstudent/widgets/text_line_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final TextLineField _nameField = TextLineField("Your name");
  final TextLineField _emailField = TextLineField("Your email address");
  final TextLineField _passwordField =
      TextLineField("New password", obscureText: true);
  final TextLineField _passwordConfirmField =
      TextLineField("Confirm new password", obscureText: true);

  @override
  void initState() {
    super.initState();

    final profile = profileProvider.userProfile;
    final user = Auth.user;
    if (profile == null || user == null) return;

    _nameField.setText(profile.name ?? "");
    _emailField.setText(user.email ?? "");
  }

  Future<bool> _updateProfile(BuildContext context) async {
    final name = _nameField.getText();
    final email = _emailField.getText();
    final password = _passwordField.getText();
    final passwordConfirm = _passwordConfirmField.getText();

    final doUpdatePassword = password.isNotEmpty || passwordConfirm.isNotEmpty;

    if (doUpdatePassword && password != passwordConfirm) {
      showError(context, "Profile error",
          description: "Passwords do not match!");
      return false;
    }

    // Update profile data if necessary (name)
    final curProfile = profileProvider.userProfile;
    if (curProfile != null && name != curProfile.name) {
      log("Updating user name");
      final newProfile = Profile(
          id: curProfile.id, name: name, avatarUrl: curProfile.avatarUrl , fcm_token: curProfile.fcm_token);
      await Auth.updateProfile(newProfile);
    }

    // Update email / password if necessary
    final userAttrs = UserAttributes();
    if (Auth.user?.email != email) {
      log("Updating email address");
      userAttrs.email = email;
    }
    if (doUpdatePassword) {
      log("Updating password");
      userAttrs.password = password;
    }

    if (userAttrs.email != null || userAttrs.password != null) {
      await Auth.updateUser(userAttrs).catchError((e) {
        if (e is AuthException) {
          showError(context, "Save error", description: e.message);
          return false;
        }
        showError(context, "Unknown error", description: e.toString());
        return false;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 16),
              _passwordConfirmField,
              const SizedBox(height: 24),
              Button('Save Changes', onPressed: () async {
                final ok = await _updateProfile(context);
                if (ok && context.mounted) Navigator.of(context).pop();
              })
            ],
          ),
        ),
      ),
    );
  }
}

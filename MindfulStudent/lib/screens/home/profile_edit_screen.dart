import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _avatarFile;

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

    String? avatarUrl;
    // Check if there is an avatar image to upload
    if (_avatarFile != null) {
      avatarUrl = await _uploadImageToSupabase(_avatarFile!);
      if (avatarUrl == null && context.mounted) {
        showError(context, "Error",
            description: "Failed to upload avatar image.");
        return false;
      }
    }

    // Update profile data if necessary (name, avatarUrl)
    final curProfile = profileProvider.userProfile;
    if (curProfile != null &&
        (name != curProfile.name || avatarUrl != curProfile.avatarUrl)) {
      log("Updating user profile");
      final newProfile = Profile(
          id: curProfile.id,
          name: name, avatarUrl: avatarUrl);
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show options to the user
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take a Picture'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    var image =
                        await picker.pickImage(source: ImageSource.camera);
                    _setImage(image);
                  }),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  var image =
                      await picker.pickImage(source: ImageSource.gallery);
                  _setImage(image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setImage(XFile? image) async {
    if (image != null) {
      File imageFile = File(image.path);

      // Upload the image to Supabase Storage
      String? imageUrl = await _uploadImageToSupabase(imageFile);

      if (imageUrl != null) {
        // Update the user's profile with the new avatar URL
        bool success =
            await updateProfileWithNewAvatar(Auth.user!.id, imageUrl);
        if (success) {
          setState(() {
            _avatarFile =
                imageFile; // Update the local UI to show the new image
          });
        } else {
          log("Failed to update user profile with new avatar URL.");
        }
      } else {
        log("Failed to upload image to Supabase.");
      }
    }
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      var imageExtension = imageFile.path.split('.').last.toLowerCase();

      final imageBytes = await imageFile.readAsBytes();
      final userId = supabase.auth.currentUser!.id;
      final imagePath = '/$userId/profile.$imageExtension';
      if (imageExtension == 'jpg') {
        imageExtension = 'jpeg';
      }
      await supabase.storage.from('avatars').uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );
      String imageUrl =
          supabase.storage.from('avatars').getPublicUrl(imagePath);
      return Uri.parse(imageUrl).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString()
      }).toString();
    } catch (e) {
      // Handle any errors during upload
      return null;
    }
  }

  Future<bool> updateProfileWithNewAvatar(
      String userId, String avatarUrl) async {
    await Supabase.instance.client
        .from('profiles')
        .update({'avatarUrl': avatarUrl})
        .eq('id', userId)
        .select();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profileProvider.userProfile?.getAvatarImage();

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
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl,
                    backgroundColor: _avatarFile == null && avatarUrl == null
                        ? const Color(0xFFC8D4D6)
                        : null,
                    child: _avatarFile == null && avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC8D4D6),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        color: const Color(0xFF497077),
                        iconSize: 15,
                        onPressed: () {
                          _pickImage();
                        },
                      ),
                    ),
                  ),
                ],
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
              const SizedBox(height: 12),
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

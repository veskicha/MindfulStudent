import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/button.dart' as button;
import 'package:mindfulstudent/widgets/text_line_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  File? _avatarFile;

  late final TextLineField _nameField = TextLineField("Your name");
  late final TextLineField _emailField = TextLineField("Your email address");
  late final TextLineField _passwordField = TextLineField(
    "New password",
    obscureText: true,
  );
  late final TextLineField _passwordConfirmField = TextLineField(
    "Confirm new password",
    obscureText: true,
  );

  @override
  void initState() {
    super.initState();

    final profile = profileProvider.userProfile;
    final user = Auth.user;
    if (profile == null || user == null) return;

    _nameField.setText(profile.name ?? "");
    _emailField.setText(user.email ?? "");
  }

  _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete account?"),
          content: const Text(
            "Are you sure you wish to delete your MindfulStudent account?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Auth.deleteAccount().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                  showSuccess(
                    context,
                    "Account deleted",
                    description: "Your account has been deleted.",
                  );
                });
              },
              child: const Text("Yes, delete my account"),
            ),
          ],
        );
      },
    );
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

    final curProfile = profileProvider.userProfile;
    if (curProfile != null) {
      bool doProfileUpdate = false;
      final newProfile = Profile(
        id: curProfile.id,
        name: curProfile.name,
        avatarUrl: curProfile.avatarUrl,
      );

      if (_avatarFile != null) {
        log("Uploading new avatar image");
        newProfile.avatarUrl = await _uploadImageToSupabase(_avatarFile!);
        if (newProfile.avatarUrl == null && context.mounted) {
          showError(context, "Error",
              description: "Failed to upload avatar image.");
          return false;
        }
        doProfileUpdate = true;
      }

      if (name != curProfile.name) {
        newProfile.name = name;
        doProfileUpdate = true;
      }

      if (doProfileUpdate) {
        log("Updating user profile");
        await Auth.updateProfile(newProfile);
      }
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
      setState(() {
        _avatarFile =
            File(image.path); // Update the local UI to show the new image
      });
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

  ImageProvider<Object>? getAvatarImage() {
    if (_avatarFile != null) {
      return FileImage(_avatarFile!);
    }

    return profileProvider.userProfile?.getAvatarImage();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profileProvider.userProfile?.getAvatarImage();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFC8D4D6),
            elevation: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Color(0xFF497077),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Customize your profile',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            foregroundColor: const Color(0xFF497077),
            leading: Transform.translate(
              offset: const Offset(0, 5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: getAvatarImage(),
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
              const SizedBox(height: 70),
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF497077),
                ),
              ),
              _nameField,
              const SizedBox(height: 20),
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF497077),
                ),
              ),
              _emailField,
              const SizedBox(height: 30),
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
              const SizedBox(height: 60),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: button.Button(
                  'Save Changes',
                  onPressed: () async {
                    final ok = await _updateProfile(context);
                    if (ok && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: button.Button('Delete account',
                    theme: button.ButtonTheme.danger, onPressed: () async {
                  _showDeleteConfirmDialog();
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

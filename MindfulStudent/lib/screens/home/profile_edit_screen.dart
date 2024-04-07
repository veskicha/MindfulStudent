import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/button.dart' as button;
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class TextLineField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final double borderRadius;
  final Color borderColor;

  const TextLineField(
    this.hintText, {
    super.key,
    this.obscureText = false,
    required this.controller,
    this.borderRadius = 20.0,
    this.borderColor = const Color(0xFFC8D4D6),
  });

  String getText() {
    return controller.text;
  }

  void setText(String text) {
    controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: const Color(0xFF497077),
      style: const TextStyle(
        color: Color(0xFF497077),
      ),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}

class EditProfilePageState extends State<EditProfilePage> {
  File? _avatarFile;
  late String? _avatarUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  late final TextLineField _nameField = TextLineField(
    "Your name",
    controller: _nameController,
    borderRadius: 20.0,
    borderColor: const Color(0xFFC8D4D6),
  );
  late final TextLineField _emailField = TextLineField(
    "Your email address",
    controller: _emailController,
    borderRadius: 20.0,
    borderColor: const Color(0xFFC8D4D6),
  );
  late final TextLineField _passwordField = TextLineField(
    "New password",
    controller: _passwordController,
    obscureText: true,
    borderRadius: 20.0,
    borderColor: const Color(0xFFC8D4D6),
  );
  late final TextLineField _passwordConfirmField = TextLineField(
    "Confirm new password",
    controller: _passwordConfirmController,
    obscureText: true,
    borderRadius: 20.0,
    borderColor: const Color(0xFFC8D4D6),
  );

  @override
  void initState() {
    super.initState();

    final profile = profileProvider.userProfile;
    final user = Auth.user;
    if (profile == null || user == null) return;

    _emailController.text = user.email ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
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
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    final doUpdatePassword = password.isNotEmpty || passwordConfirm.isNotEmpty;

    if (doUpdatePassword && password != passwordConfirm) {
      showError(context, "Profile error",
          description: "Passwords do not match!");
      return false;
    }

    String? avatarUrl;

    if (_avatarFile != null) {
      avatarUrl = await _uploadImageToSupabase(_avatarFile!);
      if (avatarUrl == null && context.mounted) {
        showError(context, "Error",
            description: "Failed to upload avatar image.");
        return false;
      }
    }

    final curProfile = profileProvider.userProfile;
    if (curProfile != null &&
        (name != curProfile.name || avatarUrl != curProfile.avatarUrl)) {
      log("Updating user profile");
      final newProfile =
          Profile(id: curProfile.id, name: name, avatarUrl: avatarUrl);
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

  ImageProvider<Object>? getAvatarImage() {
    if (_avatarFile != null) {
      return FileImage(_avatarFile!);
    } else if (_avatarUrl != null) {
      return NetworkImage(_avatarUrl!);
    }
    return null;
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

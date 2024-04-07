import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';

class ProfilePicture extends StatelessWidget {
  final Profile? profile;
  final double? radius;

  const ProfilePicture({required this.profile, this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    final img = profile?.getAvatarImage();

    if (img != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: FadeInImage(
            placeholder: const AssetImage('assets/load.gif'),
            image: img,
            fit: BoxFit.cover,
            width: radius == null ? null : radius! * 2,
            height: radius == null ? null : radius! * 2,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF497077),
      child: Icon(Icons.person, color: Colors.white, size: radius),
    );
  }
}

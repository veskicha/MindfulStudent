import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final Icon? actionIcon;
  final void Function()? onActionPressed;

  const HeaderBar(this.title,
      {this.actionIcon, this.onActionPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF497077),
      foregroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: actionIcon == null
          ? []
          : [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: IconButton(
                  icon: actionIcon!,
                  onPressed: onActionPressed,
                ),
              ),
            ],
    );
  }
}

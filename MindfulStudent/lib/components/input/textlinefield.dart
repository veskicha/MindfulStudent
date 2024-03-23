import 'package:flutter/material.dart';

class TextLineField extends StatefulWidget {
  final TextEditingController _controller = TextEditingController();

  final String hintText;
  final bool obscureText;

  TextLineField(this.hintText, {this.obscureText = false, super.key});

  @override
  TextLineFieldState createState() => TextLineFieldState();

  TextEditingController getController() {
    return _controller;
  }

  String getText() {
    return _controller.text;
  }
}

class TextLineFieldState extends State<TextLineField> {
  @override
  void dispose() {
    widget.getController().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: widget.getController(),
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF497077)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF497077)),
          ),
        ),
      ),
    );
  }
}

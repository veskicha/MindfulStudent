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

  void setText(String text) {
    _controller.text = text;
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
    return TextField(
      controller: widget.getController(),
      obscureText: widget.obscureText,
      cursorColor: const Color(0xFF497077),
      style: const TextStyle(
        color: Color(0xFF497077),
      ),
      decoration: InputDecoration(
        labelText: widget.hintText,
        labelStyle: TextStyle(color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Color(0xFFC8D4D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Color(0xFFC8D4D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Color(0xFFC8D4D6)),
        ),
      ),
    );
  }
}

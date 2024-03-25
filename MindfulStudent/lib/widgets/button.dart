import 'package:flutter/material.dart';

enum ButtonTheme {
  regular(0xFF497077);

  final int _colorValue;

  const ButtonTheme(this._colorValue);

  Color get color {
    return Color(_colorValue);
  }

  get disabledColor {
    color.withOpacity(0.9);
  }
}

class Button extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final ButtonTheme theme;

  const Button(this.text,
      {required this.onPressed, this.theme = ButtonTheme.regular, super.key});

  @override
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<Button> {
  bool _isEnabled = true;

  void _setButtonEnabled(bool state) {
    setState(() {
      _isEnabled = state;
    });
  }

  void _onButtonPress() {
    _setButtonEnabled(false);

    widget.onPressed().then((_) {
      _setButtonEnabled(true);
    }).catchError((e) {
      _setButtonEnabled(true);
      throw e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isEnabled ? _onButtonPress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.theme.color,
          disabledBackgroundColor: widget.theme.disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

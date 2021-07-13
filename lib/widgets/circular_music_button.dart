import 'package:flutter/material.dart';

class CircularMusicButton extends StatelessWidget {
  final IconData icon;
  final Color borderColor;
  final double buttonSize;
  final Function() onPressed;
  final double borderWidth;
  final double iconSize;

  const CircularMusicButton({
    @required this.icon,
    @required this.borderColor,
    @required this.buttonSize,
    this.iconSize,
    this.onPressed,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints(
        maxHeight: buttonSize,
        minWidth: buttonSize,
        minHeight: buttonSize,
        maxWidth: buttonSize,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
              width: borderWidth == null ? 3 : borderWidth,
              color: borderColor)),
      fillColor: Colors.orange,
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/app_bar_button.dart';

class MusicAppBar extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final Function() onleadingIconPressed;
  final Function() ontralingIconPressed;
  final bool padding;
  final double iconSize;
  const MusicAppBar({
    @required this.title,
    @required this.leadingIcon,
    @required this.trailingIcon,
    this.onleadingIconPressed,
    this.ontralingIconPressed,
    @required this.padding,
    @required this.iconSize,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: padding ? EdgeInsets.all(15) : EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AppBarButton(
              icon: leadingIcon,
              onPressed: onleadingIconPressed,
              size: iconSize,
            ),
            Text(
              title,
              textScaleFactor: 0.9,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailingIcon != null
                ? AppBarButton(
                    icon: trailingIcon,
                    onPressed: ontralingIconPressed,
                    size: iconSize,
                  )
                : SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

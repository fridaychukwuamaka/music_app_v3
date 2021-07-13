import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final double size;
  const AppBarButton({
 @ required this.icon,
    this.onPressed,
    @required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.all(12.2),
      constraints: BoxConstraints.tightForFinite(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      fillColor: Colors.orange,
      child: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
    );
    /* FlatButton(
      onPressed: () {},
      child: Icon(icon, size: size,),
    ); */
  }
}

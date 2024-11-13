import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../const/const.dart';

class CustomButton extends StatelessWidget {
  final dynamic onPressed;
  final String title;
  final TextStyle style = textBold;

  CustomButton(
      {super.key,
      required this.onPressed,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => onPressed),
        );
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: bgColor,
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(title,style: style),
    );
  }
}


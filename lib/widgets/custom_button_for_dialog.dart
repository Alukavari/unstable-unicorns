import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../const/const.dart';

class CustomButtonForDialog extends StatelessWidget {
  final dynamic onPressed;
  final String title;

  const CustomButtonForDialog(
      {super.key,
        required this.onPressed,
        required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed;
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: bgColor,
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(title,style: textBold),
    );
  }
}


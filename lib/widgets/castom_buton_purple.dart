import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../const/const.dart';

class CustomButtonPurple extends StatelessWidget {
  final dynamic onPressed;
  final String title;

  const CustomButtonPurple(
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

          backgroundColor: bgColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(title,style: textBoldWhite),
    );
  }
}


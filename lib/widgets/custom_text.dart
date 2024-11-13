import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final textAlign = TextAlign.center;

  const CustomText({super.key, required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.ribeye(fontWeight: FontWeight.w700, fontSize: 50), textAlign: TextAlign.center);
  }
}

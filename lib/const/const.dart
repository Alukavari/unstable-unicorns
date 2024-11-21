import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unstable_unicorns/const/colors.dart';

TextStyle textBold = GoogleFonts.ribeye(fontWeight: FontWeight.w700, fontSize: 18);
TextStyle textForDialog = GoogleFonts.ribeye(fontWeight: FontWeight.w700, fontSize: 18, color: bgColor);
TextStyle textForScroll = GoogleFonts.ribeye(fontWeight: FontWeight.w600, fontSize: 8, color: bgColor);
TextStyle textBoldWhite = GoogleFonts.ribeye(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white,);
TextStyle textBoldUnderline = GoogleFonts.ribeye(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white);
TextStyle textForSnackBar = GoogleFonts.ribeye(fontWeight: FontWeight.w200, fontSize: 15, color: Colors.white);

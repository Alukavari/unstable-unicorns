import 'package:flutter/material.dart';
import '../const/const.dart';

class SnackBarService {
  static Color? errorColor = Colors.red[200];
  static Color? okColor = Colors.green[200];

  static Future<void> showSnackBar(
      BuildContext context, String message, bool error) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(message, style: textForSnackBar),
      backgroundColor: error ? errorColor : okColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

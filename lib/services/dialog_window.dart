import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';

class DialogWindow {
  static Future<void> show(BuildContext context, String message, String title) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message,
                    style: textForDialog, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}

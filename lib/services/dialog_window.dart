import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';

import '../const/colors.dart';

class DialogWindow {
  static Future<void> show(BuildContext context,
      String message,
      String title) async {

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title, style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message,
                    style: textForDialog, textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text('ok', style: textBoldWhite),
                ),
              ],
            ),
          ),
        );
      },

    );
    // Timer(const Duration(seconds: 4),(){
    //   Navigator.of(context).pop();
    // },
    // );

  }
}


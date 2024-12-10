import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';

class DialogWindow {
  static Future<void> show(
      BuildContext context,
      String message,
      String title
      ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        //добавили
        // Future.delayed(const Duration(seconds: 5), () {
        //
        //   // Timer(const Duration(seconds: 5),(){
        //   // Navigator.of(context).pop();
        //   if (Navigator.of(dialogContext).canPop()) {
        //     Navigator.of(dialogContext).pop();
        //   }
        // });
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

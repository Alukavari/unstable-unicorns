import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_unicorns/const/const.dart';
import '../../const/colors.dart';

class DialogForFunction {
  static Future<void> show(
      BuildContext context,
      String description,
      String roomName,
      Function onYesPressed,
      Function onYesPressed2,

      )async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title:
          Text(description, style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('tap yes');
                          await onYesPressed();
                          print('tap yes done in dialog function');
                          Navigator.of(dialogContext).pop();

                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text('yes',
                            style: textBoldWhite, textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('tap no');
                          await onYesPressed2();
                          print('tap yes done in dialog function');

                          Navigator.of(dialogContext).pop();
                          // здесь отображается ваш второй конте
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text('no',
                            style: textBoldWhite, textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unstable_unicorns/widgets/custom_button.dart';
import '../const/colors.dart';
import '../const/const.dart';
import '../models/game_state.dart';
import '../widgets/custom_button_for_dialog.dart';

class DialogWithoutTPRU {
  static Future<void> show(
      BuildContext context,
      final onPressedNextPlayer,
      final onPressedDrawCard,
      ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Notification',
              style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 120,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('You don’t have TPRU cards but you can play for time and create an illusion~ or just end the move',
                      style: textForDialog, textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: () {
                      onPressedNextPlayer();
                      onPressedDrawCard();
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                      // Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: bgColor,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('end move', style: textBold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

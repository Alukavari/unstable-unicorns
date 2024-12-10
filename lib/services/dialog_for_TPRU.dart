import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unstable_unicorns/widgets/custom_button.dart';
import '../const/colors.dart';
import '../const/const.dart';
import '../models/game_state.dart';
import '../widgets/custom_button_for_dialog.dart';

class DialogForTPRU {

  static Future<void> show(
    BuildContext context,
    final onPressedDrawTPRU,
    final onPressedNextPlayer,
    final onPressedDrawCard,
    final onPressedCheckTPRU,

  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // builder: (BuildContext context) {
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
                  Text('You have TPRU cards, do you want to cancel the move?',
                      style: textForDialog, textAlign: TextAlign.center),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          onPressedDrawTPRU();
                          onPressedNextPlayer();
                          if (Navigator.of(dialogContext).canPop()) {
                            Navigator.of(dialogContext).pop();
                          }
                          // Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: bgColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text('play TPRU', style: textBold),
                      ),
                      const SizedBox(width: 10),
                      CustomButtonForDialog(
                        onPressed: () {
                          onPressedNextPlayer();
                          onPressedDrawCard();
                          if (Navigator.of(dialogContext).canPop()) {
                            Navigator.of(dialogContext).pop();
                          }

                          // Navigator.of(context).pop();
                        },
                        title: 'no',
                      ),
                    ],
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

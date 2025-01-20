import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/screens/lobby.dart';
import 'package:unstable_unicorns/services/dialog/dialog_for_game.dart';
import 'package:unstable_unicorns/widgets/button/custom_button_for_dialog.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_game.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_moving_card.dart';
import '../../const/colors.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../widgets/button/castom_buton_purple.dart';
import '../../widgets/button/custom_button.dart';

class DialogForGameChoose {
  static Future<void> show(
    BuildContext context,
    String description,
    String myID,
    String otherID,
    String roomName,
    String titleButton,
    String titleButton2,
      Widget content1,
      Widget content2,
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
                          print('мы тут нажали кнопку отдать бонус');
                          showDialog(
                            context: dialogContext,
                            builder: (BuildContext innerDialogContext) {
                              return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: SingleChildScrollView(
                                  child: ListBody(
                                  children: <Widget>[
                                      Center(
                                      child: content1),
          ]
                                // здесь отображается ваш второй контент

                                  ),
                                  ),
                              );
                            },
                          );
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text(titleButton,
                            style: textBoldWhite, textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('мы тут нажали кнопку забрать бонус');
                          showDialog(
                            context: dialogContext,
                            builder: (BuildContext innerDialogContext) {
                              return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                        children: <Widget>[
                                        Center(
                                        child: content2), // здесь отображается ваш второй контент
                                        ]
                                      // здесь отображается ваш второй контент

                                    ),
                                  ),
                              );
                            },
                          );
                          Navigator.of(dialogContext).pop();

                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text(titleButton2,
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

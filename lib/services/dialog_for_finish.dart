import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/screens/lobby.dart';
import '../const/colors.dart';
import '../models/game.dart';
import '../widgets/castom_buton_purple.dart';
import '../widgets/custom_button.dart';

class DialogForFinish {
  static Future<void> show(
    BuildContext context,
    String message,
    String title,
    String myEmail,
    String myID,
    String roomName,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        print('мы на диалоге когда объявлен победитель');
        return AlertDialog(
          title: Text(title, style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: textForDialog,
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonPurple(
                          onPressed: Lobby(userCredential: myID, email: myEmail),
                          title: 'new game'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton( 
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/signIn');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text('exit', style: textBoldWhite),
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

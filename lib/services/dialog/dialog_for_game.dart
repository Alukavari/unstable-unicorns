import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_game.dart';
import '../../models/card.dart';

class DialogForGame {
  static Future<void> show(
      BuildContext context,
      String title,
      String roomName,
      List<CardModel>? deck,
      String myID,
      String otherID,
Widget content,
      ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 120, //поменяли
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: content)

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

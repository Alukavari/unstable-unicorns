import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/widgets/scroll_widget_for_deck.dart';
import '../models/card.dart';

class DialogForDeck {
  static Future<void> show(
      BuildContext context,
      int count,
      String title,
      String roomName,
      List<CardModel> deck,
      String typeDeck,
      String typeGameDeck,
      String currentPlayer) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: textForDialog, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: SizedBox(
            //добвили
            width: 120, //поменяли
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: ScrollWidgetForDeck(
                      roomName: roomName,
                      typeDeck: typeDeck,
                      typeGameDeck: typeGameDeck,
                      gameDeck: deck,
                      playerID: currentPlayer,
                      count: count,
                      title: title,
                    ),
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

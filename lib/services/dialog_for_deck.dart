import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/widgets/scroll_widget.dart';
import 'package:unstable_unicorns/widgets/scroll_widget_for_deck.dart';
import '../models/card.dart';

class DialogForDeck {
  static Future<void> show(BuildContext context, int count, String title, List<CardModel> deck,
      String roomName, String typeDeck, String typeGameDeck, String currentPlayer) {


    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(title, style: textForDialog)),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(children: [
              SizedBox(
                height: 170,
                child: ScrollWidgetForDeck(
                    deck: deck,
                    roomName: roomName,
                    typeDeck: typeDeck,
                    typeGameDeck: typeGameDeck,
                    playerID: currentPlayer,
                count: count),
              )
            ],
            ),
          ),
        );
      },
    );
  }
}

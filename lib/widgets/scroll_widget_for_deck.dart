import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';
import '../models/card.dart';
import '../models/deck.dart';

class ScrollWidgetForDeck extends StatelessWidget {
  String roomName;
  String typeDeck;
  String typeGameDeck;
  String playerID;
  List<CardModel> deck;
  int count;

  ScrollWidgetForDeck({
    super.key,
    required this.roomName,
    required this.typeDeck,
    required this.typeGameDeck,
    required this.playerID,
    required this.deck,
    required this.count,
  });


  @override
  Widget build(BuildContext context) {

    List<CardModel> selectedDeck = [];
    if(deck.length >= count){
      for(int i =0; i < count; i++){
        selectedDeck.add(deck.last);
        deck.remove(deck.last);
      }
    }else{
      DialogWindow.show(context, 'Игра окончена, недостаточно карт для данного действия', 'Upps..');
    }

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: selectedDeck.length,
      itemBuilder: (context, index) {
        return Container(
          width: 110,
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () {
              Deck.addCardsPlayerDeck(
                  roomName, selectedDeck, typeDeck, typeGameDeck, playerID);
            },
            child: Center(
              child: Text(
                'add',
                style: textForDialog,
              ),
            ),
          ),
        );
      },
    );
  }
}

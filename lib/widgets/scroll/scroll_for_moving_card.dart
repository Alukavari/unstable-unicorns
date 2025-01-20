import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/deck.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollForMovingCard extends StatelessWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  int countDiscard;
  Function (BuildContext context, CardModel? card) onCardTap; // Функция обратного вызова для onTap


  ScrollForMovingCard({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.countDiscard,
    required this.onCardTap,
  });


  int count = 0;

  void _onTap(
      BuildContext context,
      CardModel? card,
      ) async {
    if(count < countDiscard) {
      await onCardTap(context, card);
      await Game.incrementCardAction(roomName);
      count++;
      if(count >= countDiscard ){
        await Game.cleanCardAction(roomName);
        await PlayerState.removeCardFromPlayerDeck(roomName, card!, 'stall', myID);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 110, //
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: cards?.length,
          itemBuilder: (context, index) {
            return Container(
              width: 110,
              margin: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () {
                  _onTap(context, cards![index]);
                },
                onDoubleTap: () {
                  DialogWindow.show(
                      context, cards![index].description, cards![index].name);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                      cards![index].imageUrl,
                      fit: BoxFit.contain
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


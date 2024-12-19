import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/const.dart';
import '../models/card.dart';
import '../models/game.dart';
import '../provider/current_player_provider.dart';
import '../services/dialog_window.dart';
import '../provider/game_data_provider.dart';

class ScrollWidgetBonuses extends StatelessWidget {
  List<CardModel> cards;
  String roomName;
  String myID;

  ScrollWidgetBonuses({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
  });



  @override

  Widget build(BuildContext context) {

    final currentPlayer = Provider.of<CurrentPlayerState>(context).currentPlayer;
    final isMyTurn = currentPlayer == myID;
    // final GameDataProvider gameData = GameDataProvider();

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () {
              // if(gameData.actCount == 0 && isMyTurn){
              // if(Provider.of<GameDataProvider>(context, listen: false).actCount == 0 && isMyTurn){
                //действие карты
              // }
            },
            onDoubleTap: () {
              DialogWindow.show(
                  context, cards[index].description, cards[index].name);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.white,
                width: 80,
                height: 30,
                child: Center(child: Text(cards[index].name, style: textForFB, textAlign: TextAlign.center)),
              )

              ),
            ),
        );
      },
    );
  }
}

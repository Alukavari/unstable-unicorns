import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../services/current_player_provider.dart';
import '../services/dialog_window.dart';
import '../services/game_data_provider.dart';

class ScrollCard extends StatelessWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  String otherID;

  ScrollCard({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.otherID,
  });

  void _handleTap(BuildContext context,
      CardModel newCards,
      GameDataProvider gameData,
      String roomName,
      String currentPlayer,) {
    print('мы в скрол actCount ${gameData.actCount}');
    if (gameData.actCount == 1) {
      Player.playCard(
        context,
        roomName,
        currentPlayer,
        newCards,
        myID,
        otherID,
      );
      gameData.incrementActCount();
    } else if (gameData.actCount == 0) {
      DialogWindow.show(
          context,
          'Take a card from the deck',
          'Notification');
    } else if (gameData.actCount == 2) {
      print('мы в скрол кард и count = ${gameData.actCount}');
      DialogWindow.show(
          context,
          'You have finished your turn',
          'Nooo~');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;
    final isMyTurn = currentPlayer == myID;

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards!.length,
      itemBuilder: (context, index) {
        return Container(
          width: 110,
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: isMyTurn
                ? () =>
                _handleTap(
                    context,
                    cards![index],
                    Provider.of<GameDataProvider>(context, listen: false),
                    roomName,
                    currentPlayer,
                )
                : () {},
            onDoubleTap: () {
              DialogWindow.show(
                  context, cards![index].description, cards![index].name);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                cards![index].imageUrl,
                fit: BoxFit.cover,
                width: 110,
                height: 170,
              ),
            ),
          ),
        );
      },
    );
  }
}


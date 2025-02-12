import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/widgets/button/custom_button.dart';
import '../../const/colors.dart';
import '../../const/const.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../widgets/button/custom_button_for_dialog.dart';
import '../../provider/current_player_provider.dart';
import '../../provider/game_data_provider.dart';

class DialogWithoutTPRU {
  static Future<void> show(
    BuildContext context,
    String roomName,
      String myID,
      String otherID,
      CardModel? newCard,
  ) {

    Future<void> onHandTap()async{
      await Game.changeGameStatus('inProcess', roomName);
      bool isEven = await Player.checkCardOnTableForDraw(roomName);
      String currentPlayer = Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;

      await Game.changeGameStatus('inProcess', roomName);
      await Game.nextPlayer(
    roomName,
    currentPlayer,
    myID,
    otherID,
    );

      if (!isEven) {
        print(' разыгрывет карту в диалоге bez tpru');

        await Player.activateCard(
          context,
          newCard!,
          roomName,
          myID,
          otherID,
        );

      } else{
        print('не разыгырваем карту в диалоге без тпру');
        await Game.cleanActCount(roomName);
      }
      final deckCard = await GameState.getDeck(roomName, 'playingCardOnTable');

      if (deckCard.isNotEmpty && newCard!.name != 'НОСОРОГОРОГ') {
        await GameState.addNewGameDeck(roomName, deckCard, 'discardPile');
      }
        await GameState.removeAllGameDeck(
          roomName,
          'playingCardOnTable',
        );

    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  Text('You can\'t stop the move',
                      style: textForDialog, textAlign: TextAlign.center),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                        newCard!.imageUrl,
                        fit: BoxFit.cover),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        onHandTap();
                      } catch (e) {
                        print('не было TPRU: $e');
                      } finally {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text('end move', style: textBoldWhite),
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

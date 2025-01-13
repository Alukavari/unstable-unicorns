import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/card.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/widgets/button/castom_buton_purple.dart';
import 'package:unstable_unicorns/widgets/button/custom_button.dart';
import '../../const/colors.dart';
import '../../const/const.dart';
import '../../models/game.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../models/player_state.dart';
import '../../widgets/button/custom_button_for_dialog.dart';

class DialogForTPRU {
  static Future<void> show(BuildContext context,
      CardModel tpru,
      String currentPlayer,
      String myID,
      String otherID,
      CardModel? newCard,
      String roomName,) {

    Future<void> onHandTap() async {
      bool isEven = tpru.id == '15tpru' ? true : false;
      //разыграть тпру
      await GameState.updateWithNewCardGameDeck(
        roomName,
        tpru,
        'playingCardOnTable',
      );
      //удалить тпру с рук
      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        tpru,
        'hand',
Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
      );

      if (isEven) {
        bool isDrawnCard =  await Player.checkCardOnTableForDraw(roomName);
        await Game.changeGameStatus('inProcess', roomName);

        if (!isDrawnCard ){
          await Player.activateCard(
            context,
            newCard!,
            roomName,
            myID,
            otherID,
          );
          // await Game.checkCountCardOnHand(
          //   context,
          //   roomName,
          //   'hand',
          //   Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
          //   myID,
          //   otherID,
          // );
        }
          await Game.cleanActCount(roomName);
          print('обнуляем коунт после розыгрыша карты ${Provider
              .of<GameDataProvider>(context, listen: false)
              .actCount}');

        final deckCard = await GameState.getDeck(
            roomName, 'playingCardOnTable');
        // print('сколько карт на столе ${deckCard.length}');

        if(deckCard.isNotEmpty){
          await GameState.addNewGameDeck(roomName, deckCard, 'discardPile');
          await GameState.removeNewGameDeck(
            roomName,
            'playingCardOnTable',
          );
        }

        // print('удаляем все карты со стола');

        await Game.nextPlayer(
          roomName,
          // currentPlayer,
          Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
          myID,
          otherID,
        );
      }
      //onPressedNextPlayer
      await Game.nextPlayer(
        roomName,
        // currentPlayer,
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
        myID,
        otherID,
      );
    }

    Future<void> onHandTapTwo() async {
      // выйграна ли битва тпру разыгрываем ли мы карту
      bool isEven = await Player.checkCardOnTableForDraw(roomName);
      await Game.changeGameStatus('inProcess', roomName);
      await Game.nextPlayer(
        roomName,
        Provider
            .of<CurrentPlayerState>(context, listen: false)
            .currentPlayer,
        myID,
        otherID,
      );

      if (!isEven) {
        // разыгрывет карту
        await Player.activateCard(
          context,
          newCard!,
          roomName,
          myID,
          otherID,
        );
      // await Game.checkCountCardOnHand(
      //   context,
      //   roomName,
      //   'hand',
      //   Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
      //   myID, otherID,
      // );
    }

      await Game.cleanActCount(roomName);
      // print('обнуляем коунт после розыгрыша карты ${Provider
      //     .of<GameDataProvider>(context, listen: false)
      //     .actCount}');

    final deckCard = await GameState.getDeck(
    roomName, 'playingCardOnTable');
if(deckCard.isNotEmpty){
  await GameState.addNewGameDeck(roomName, deckCard, 'discardPile');
  await GameState.removeNewGameDeck(
    roomName,
    'playingCardOnTable',
  );
}

  }

      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Consumer<CurrentPlayerState>(
            builder: (context, currentPlayerState, child) {
              return AlertDialog(
                title: Text('Notification',
                    style: textForDialog, textAlign: TextAlign.center),
                backgroundColor: Colors.white,
                content: SizedBox(
                  width: 120,
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            'You have TPRU cards, do you want to cancel the move?',
                            style: textForDialog,
                            textAlign: TextAlign.center),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // print('мы тут разыгрываем тпру');
                                try {
                                  onHandTap();
                                } catch (e) {
                                  print('Error playing TPRU: $e');
                                } finally {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: bgColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text('play TPRU', style: textBoldWhite),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                // print('мы тут отказываемся разыгрывать тпру');
                                try {
                                  onHandTapTwo();
                                } catch (e) {
                                  // print('отказались играть TPRU: $e');
                                } finally {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: bgColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text('no', style: textBoldWhite),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
}

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

class DialogForKillTPRU {
  static Future<void> show(
      BuildContext context,
      String currentPlayer,
      String myID,
      String otherID,
      CardModel? newCard,
      CardModel? tpru,
      CardModel? killTpru,
      List<CardModel>? handCards,
      String roomName,
      ) {
    //убойное тпру
    Future<void> onHandTap() async {
      //разыграть убойное тпру
      await Game.changeGameStatus('inProcess', roomName);
      //разыграть тпру
      await GameState.updateWithNewCardGameDeck(
        roomName,
        killTpru!,
        'playingCardOnTable',
      );
      //удалить тпру с рук
      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        killTpru,
        'hand',
        Provider
            .of<CurrentPlayerState>(context, listen: false)
            .currentPlayer,
      );

      bool isDrawnCard = await Player.checkCardOnTableForDraw(roomName);

      if (!isDrawnCard) {
        await Player.activateCard(
          context,
          newCard!,
          roomName,
          myID,
          otherID,
        );
      }
      await Game.cleanActCount(roomName);
      print('обнуляем коунт после розыгрыша карты ${Provider
          .of<GameDataProvider>(context, listen: false)
          .actCount}');

      final deckCard = await GameState.getDeck(roomName, 'playingCardOnTable');

      if (deckCard.isNotEmpty && newCard!.name != 'НОСОРОГОРОГ') {
        await GameState.addNewGameDeck(roomName, deckCard, 'discardPile');
      }
      await GameState.removeAllGameDeck(
        roomName,
        'playingCardOnTable',
      );

    }
    //разыграть обычное тпру
    Future<void> onHandTapTwo () async {
      await GameState.updateWithNewCardGameDeck(
        roomName,
        tpru!,
        'playingCardOnTable',
      );
      //удалить тпру с рук
      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        tpru,
        'hand',
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
      );

      //onPressedNextPlayer
      await Game.nextPlayer(
        roomName,
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
        myID,
        otherID,
      );

    }

    //вообще не разыгрывать тпру
    Future<void> onHandTapThree() async {
      //не разыгрывтаь тпру вообще
      bool isEven = await Player.checkCardOnTableForDraw(roomName);
      print('выйграна ли битва тпру разыгрываем ли мы карту $isEven');
      await Game.changeGameStatus('inProcess', roomName);
      await Game.nextPlayer(
        roomName,
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
        myID,
        otherID,
      );
      if (!isEven) {
        print(' разыгрывет карту в диалоге с тпру');
        await Player.activateCard(
          context,
          newCard!,
          roomName,
          myID,
          otherID,
        );
      } else {
        print('не разыгырваем карту в диалоге с тпру');
        await Game.cleanActCount(roomName);
      }

      final deckCard = await GameState.getDeck(roomName, 'playingCardOnTable');
      if (deckCard.isNotEmpty) {
        await GameState.removeAllGameDeck(
          roomName,
          'playingCardOnTable',
        );
        await GameState.addNewGameDeck(roomName, deckCard, 'discardPile');
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
                          'You have TPRU card, do you want to cancel the card ${newCard!.name}?',
                              // ' Description: "${newCard!.description}"',
                          style: textForDialog,
                          textAlign: TextAlign.center),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                            newCard!.imageUrl,
                            fit: BoxFit.cover),
                      ),
                      Column(
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
                            child: Text('play kill TPRU', style: textBoldWhite),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              // print('мы тут разыгрываем тпру');
                              try {
                                onHandTapTwo();
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
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                onHandTapThree();
                              } catch (e) {
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

                        ]
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../provider/current_player_provider.dart';
import '../../services/dialog/dialog_window.dart';
import '../../provider/play_out_card_provider.dart';
import '../../provider/game_data_provider.dart';

class ScrollHandCard extends StatelessWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  String otherID;

  ScrollHandCard({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.otherID,
  });

  Future<void> _handleTap(BuildContext context,
      CardModel newCard,
      String roomName,
      String currentPlayer,) async {
    print('мы в скрол actCount ${ Provider.of<GameDataProvider>(context, listen: false).actCount}');

    List<CardModel> deckCard = await GameState.getDeck(roomName, 'deck');
    int countDeck = deckCard.length ?? 0;
    bool isEvenRainbowAura = false;
    bool isEvenCardForSacrifice = false;
    bool isEvenCardForDestroy = false;

    if (countDeck == 0) {
      await Game.checkVictoryConditions(roomName, currentPlayer);
    }

    if(myID == Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer ){
      if (newCard.name == 'ЕДИНОРОЖИЙ ЯД') {
        isEvenRainbowAura = await CardModel.checkHaveUnicornForDestroy(
          context, roomName, otherID);
        print('карта единорожий яд');

      }
      else if (newCard.name == 'ДВА ПО ЦЕНЕ ОДНОГО'){
        isEvenCardForSacrifice = await CardModel.checkHaveCardForSacrifice(context, roomName, myID);
        isEvenCardForDestroy = await CardModel.checkHaveCardForDestroy(context, roomName, otherID);
        print('карта единорожий яд');

      }
      //0
      if (
          Provider
              .of<GameDataProvider>(context, listen: false)
              .actCount == 0) {
        DialogWindow.show(context, 'Take a card from the deck', 'Notification');

        //1
      } else if (
          Provider
              .of<GameDataProvider>(context, listen: false)
              .actCount == 1) {
        if (newCard.type == CardClass.tpru) {
          DialogWindow.show(
              context, 'You can\'t play TPRU, choose another card',
              'Notification');
        }else if (
        newCard.name == 'ЕДИНОРОЖИЙ ЯД' && !isEvenRainbowAura) {
          print('ne mogu sigrat edinirizi ayd');
          String? opponentName = await Game.getUserNicknameByEmail(otherID);
          DialogWindow.show(context,
              'You cannot use this card, $opponentName has the bonus РАДУЖНАЯ АУРА. Change another card',
              'Notification');
        }else if (newCard.name == 'ДВА ПО ЦЕНЕ ОДНОГО' && !isEvenCardForSacrifice && !isEvenCardForDestroy){
          print('не могу сыгырать два по цене одного');
          DialogWindow.show(context,
              'You cannot implement one of the card conditions. Change another card',
              'Notification');
        } else {
          await Game.updatePlayOutCard(
            roomName,
            newCard,
          );
          await Player.playCard(
            context,
            roomName,
            currentPlayer,
            myID,
            otherID,
          );
          await Game.incrementActCount(roomName);
          print('сколько теперь каунт потмоу что мы добавили1 ${Provider
              .of<GameDataProvider>(context, listen: false)
              .actCount}');
        }
      //2
      }else if (Provider
          .of<GameDataProvider>(context, listen: false)
          .actCount == 2) {
        DialogWindow.show(
            context, 'You have finished change your turn', 'Notification');
        //3
      } else if (Provider.of<GameDataProvider>(context, listen: false).actCount >= 3
          // && Provider
          // .of<GameDataProvider>(context, listen: false)
          // .actCount < 10
      ) {
        if (Provider
            .of<DiscardCardProvider>(context, listen: false)
            .discardCard !=
            0) {
          await GameState.updateWithNewCardGameDeck(
              roomName, newCard, 'discardPile');
          await PlayerState.removeCardFromPlayerDeck(
              roomName, newCard, 'hand', currentPlayer);
          Provider.of<DiscardCardProvider>(context, listen: false)
              .decreaseDiscardCard();
        }
      }
    }

    // if (newCard.name == 'ЕДИНОРОЖИЙ ЯД') {
    //   print('карта единорожий яд');
    //   bool isEven = await CardModel.checkSpellUnicornPoison(roomName, otherID, context);
    //
    //   if (newCard.name == 'ЕДИНОРОЖИЙ ЯД' && !isEven) {
    //     String? opponentName = await Game.getUserNicknameByEmail(otherID);
    //     DialogWindow.show(context,
    //         'You cannot use this card, $opponentName has the bonus РАДУЖНАЯ АУРА. Change another card',
    //         'Notification');
    //   }
    // }else if (newCard.type == CardClass.tpru) {
    //     print('тиа карты ${newCard.type}  и проверяемый тип ${CardClass.tpru}');
    //     DialogWindow.show(
    //         context, 'You can\'t play TPRU, choose another card',
    //         'Notification');
    //   }
    // else if (
    // myID == currentPlayer
    //     &&
    //     Provider
    //         .of<GameDataProvider>(context, listen: false)
    //         .actCount == 0) {
    //   DialogWindow.show(context, 'Take a card from the deck', 'Notification');
    // } else if (
    // myID == currentPlayer
    //     &&
    //     Provider
    //       .of<GameDataProvider>(context, listen: false)
    //       .actCount == 1) {
    //     await Game.updateDrawCard(
    //       roomName,
    //       newCard,
    //     );
    //     await Player.playCard(
    //       context,
    //       roomName,
    //       currentPlayer,
    //       myID,
    //       otherID,
    //     );
    //     await Game.incrementActCount(roomName);
    //     print('сколько теперь каунт потмоу что мы добавили1 ${Provider
    //         .of<GameDataProvider>(context, listen: false)
    //         .actCount}');
    //   }  else if (Provider
    //       .of<GameDataProvider>(context, listen: false)
    //       .actCount == 2) {
    //     DialogWindow.show(
    //         context, 'You have finished change your turn', 'Notification');
    //   } else if (Provider.of<GameDataProvider>(context, listen: false).actCount >= 3 && Provider
    //           .of<GameDataProvider>(context, listen: false)
    //           .actCount < 10) {
    //     if (Provider
    //         .of<DiscardCardProvider>(context, listen: false)
    //         .discardCard !=
    //         0) {
    //       await GameState.updateWithNewCardGameDeck(
    //           roomName, newCard, 'discardPile');
    //       await PlayerState.removeCardFromPlayerDeck(
    //           roomName, newCard, 'hand', currentPlayer);
    //       Provider.of<DiscardCardProvider>(context, listen: false)
    //           .decreaseDiscardCard();
    //     }
    //   }
    }

    @override
    Widget build(BuildContext context) {
      final currentPlayer = Provider
          .of<CurrentPlayerState>(context, listen: false)
          .currentPlayer;
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

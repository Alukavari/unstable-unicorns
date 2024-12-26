import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import 'package:unstable_unicorns/widgets/scroll_for_game.dart';
import '../provider/current_player_provider.dart';
import '../provider/draw_card_provider.dart';
import '../services/dialog_for_TPRU.dart';
import '../services/dialog_whithoutTPRU.dart';
import 'card.dart';
import 'game.dart';
import 'game_state.dart';

class Player {
  //разыгрываем карту
  static Future<void> playCard(BuildContext context,
      String roomName,
      String currentPlayer,
      String myID,
      String otherID,) async {
    print('текущий игрок на розыгрыше карт ${currentPlayer}');
    CardModel? newCard = await Game.getDrawCard(roomName);
    print('разыгрываемая карта ${newCard?.name}');

    if (newCard?.type == CardClass.tpru) {
      print('это тпру карта');
      // SnackBarService.showSnackBar(context, 'You can\'t play TPRU, choose another card', true);
      DialogWindow.show(context, 'You can\'t play TPRU, choose another card', 'Notification');
    } else {
      print('нет не тпру разыгрываем');
      await GameState.updateWithNewCardGameDeck(
        roomName,
        newCard!,
        'playingCardOnTable',
      );
      print('добавили карут на стол');

      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        newCard,
        'hand',
        currentPlayer,
      );
      print('удалили на руках');
      print('обновили игрока старый текущий игрок ${currentPlayer}');
      await Game.nextPlayer(
        roomName,
        currentPlayer,
        myID,
        otherID,
      );

      String newCurrentPlayer = Provider
          .of<CurrentPlayerState>(context, listen: false)
          .currentPlayer;
      print('новый текущий игрок currentPlayer ${newCurrentPlayer}');

      String? userNickname = await Game.getNicknameById(
        otherID,
        roomName,
      );
      print('получили имя соперника $userNickname');
      print('меняем статус на чекТПРУ');
      await Game.changeGameStatus(
        'checkTPRU',
        roomName,
      );
      if (newCurrentPlayer != myID) {
        SnackBarService.showSnackBar(context, 'Player $userNickname makes a move', false);
        // DialogWindow.show(context, 'Player $userNickname makes a move', 'Wait');
      }
    }
  }

  //проверка на наличие тпру у игрока
  static Future<void> checkTPRU(
      BuildContext context,
      String currentPlayer,
      String myID,
      String otherID,
      String roomName,
      ) async {
    print('мы перешли на чекТПРУ');

// получаем значение разыгрываемой карты
    CardModel? newCard = await Game.getDrawCard(roomName);
    print('разыгрываемая карта ${newCard?.name}');

    List<CardModel> handCards = await PlayerState.getPlayerDeck(
      roomName,
      'hand',
      currentPlayer,
    ) as List<CardModel>;

    bool hasTpruCard = handCards.any((card) => card.type == CardClass.tpru);
    print('проверяем наличие тпру у $currentPlayer и это $hasTpruCard');

    if (hasTpruCard) {
      print('есть тпру');
      CardModel tpru =
      handCards.firstWhere((card) => card.type == CardClass.tpru);

      print('мы на диалоге для тпру');
      await DialogForTPRU.show(
        context,
        tpru,
        currentPlayer,
        myID,
        otherID,
        newCard,
        roomName,
      );
    } else {
      //если отказывается выкладывать тпру
      print('$currentPlayer отказался выкладывать тпру');
      await DialogWithoutTPRU.show(
        context,
        roomName,
        myID,
        otherID,
        newCard,
      );
    }
  }


//разыгрываем функцию карты
  static Future<void> activateCard(
      BuildContext context,
      CardModel newCard,
      String roomName,
      String myID,
      String otherID,
      ) async {
    String currentPlayer =
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;

    String otherId = currentPlayer == myID ? otherID : myID;

    final deckCard = await GameState.getDeck(roomName, 'playingCardOnTable');
    if (deckCard.isNotEmpty) {

      // вот тут реализация розыгрыша карты
      if (newCard.type == CardClass.unicorn) {
        await CardModel.drawnUnicorn(context, roomName, newCard, myID, otherID);

      } else if (newCard.type == CardClass.bonus) {
        await PlayerState.addCardsPlayerDeck(
            roomName, newCard, 'bonuses', currentPlayer);
        await GameState.removeCardGameDeck(
          roomName,
          newCard,
          'playingCardOnTable',
        );
        await Game.cleanActCount(roomName);

      } else if (newCard.type == CardClass.fine) {
        await PlayerState.addCardsPlayerDeck(
            roomName, newCard, 'fines', otherId);

        await GameState.removeCardGameDeck(
          roomName,
          newCard,
          'playingCardOnTable',
        );
        await Game.cleanActCount(roomName);
      }
    }

    print('конец розыгрыша карты на стол');

    await Game.updateDrawCard(
      roomName,
      null,
    );

    await Game.changeGameStatus('inProcess', roomName);
  }




  //проверяем можно ли разыгрывать карту после битвы тпру
  static Future<bool> checkCardOnTableForDraw(String roomName) async {
    try {
      List<CardModel> cardOnTable =
      await GameState.getDeck(roomName, 'playingCardOnTable');
      print('проверяем четность карт есть ли колода ${cardOnTable.length}');

      int countCard = cardOnTable.length;
      return countCard % 2 == 0 ? true : false;
    } catch (e) {
      print('Error fetching cards from table: $e');
      return false;
    }
  }


// сбросить карту мне
 static Future<void> cardDiscard(
     BuildContext context,
     String roomName,
     CardModel newCard,
     String myID,
     )async {

       await GameState.updateWithNewCardGameDeck(
           roomName, newCard, 'discardPile');
       await PlayerState.removeCardFromPlayerDeck(
           roomName, newCard, 'hand', myID);
     }
}

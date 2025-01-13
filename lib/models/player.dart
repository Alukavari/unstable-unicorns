import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/services/dialog/dialog_window.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_game.dart';
import '../const/immortal_unicorns.dart';
import '../provider/current_player_provider.dart';
import '../provider/play_out_card_provider.dart';
import '../services/dialog/dialog_for_TPRU.dart';
import '../services/dialog/dialog_whithoutTPRU.dart';
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
    // print('текущий игрок на розыгрыше карт ${currentPlayer}');
    CardModel? newCard = await Game.getPlayOutCard(roomName);
    print('разыгрываемая карта в плэйкард ${newCard?.name}');

    if (newCard?.type == CardClass.tpru) {
      DialogWindow.show(context, 'You can\'t play TPRU, choose another card', 'Notification');
    } else {
      await GameState.updateWithNewCardGameDeck(
        roomName,
        newCard!,
        'playingCardOnTable',
      );

      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        newCard,
        'hand',
        currentPlayer,
      );
      await Game.nextPlayer(
        roomName,
        currentPlayer,
        myID,
        otherID,
      );

      // String newCurrentPlayer = Provider
      //     .of<CurrentPlayerState>(context, listen: false)
      //     .currentPlayer;

      // String? userNickname = await Game.getNicknameById(
      //   otherID,
      //   roomName,
      // );
      await Game.changeGameStatus(
        'checkTPRU',
        roomName,
      );
      // if (newCurrentPlayer != myID) {
      //   SnackBarService.showSnackBar(context, 'Player $userNickname makes a move', false);
      // }
    }
  }

  //проверка на наличие тпру у игрока
  static Future<void> checkTPRU(
  // static Future<bool> checkTPRU(
      BuildContext context,
      String currentPlayer,
      String myID,
      String otherID,
      String roomName,
      ) async {
    // print('мы перешли на чекТПРУ');

// получаем значение разыгрываемой карты
    CardModel? newCard = await Game.getPlayOutCard(roomName);
    print('разыгрываемая карта в чектпру ${newCard?.name}');

    List<CardModel> handCards = await PlayerState.getPlayerDeck(
      roomName,
      'hand',
      currentPlayer,
    ) as List<CardModel>;

    bool hasTpruCard = handCards.any((card) => card.type == CardClass.tpru);

    if (hasTpruCard) {
      // print('есть тпру');
      CardModel tpru = handCards.firstWhere((card) => card.type == CardClass.tpru);

      // print('мы на диалоге для тпру');
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
      // print('$currentPlayer отказался выкладывать тпру');
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
      // CardModel? newCard,
      CardModel newCard,
      String roomName,
      String myID,
      String otherID,
      ) async {
    String currentPlayer = Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;

    String otherId = currentPlayer == myID ? otherID : myID;
//единорог
      if (newCard.type == CardClass.unicorn) {
        print('тип карты единорог');

        await CardModel.playOutUnicorn(
            context, roomName, newCard, myID, otherID);

        //бонус
      } else if (newCard.type == CardClass.bonus) {
        print('тип карты бонус');

        await PlayerState.addCardsPlayerDeck(
            roomName, newCard, 'bonuses', currentPlayer);
        await GameState.removeCardGameDeck(
          roomName,
          newCard,
          'playingCardOnTable',
        );
        await Game.checkCountCardOnHand(
          context,
          roomName,
          'hand',
          Provider
              .of<CurrentPlayerState>(context, listen: false)
              .currentPlayer,
          myID,
          otherID,
        );
        await Game.updatePlayOutCard(roomName, null);
        print('обнулили карту в бонусах');

        //штраф
      } else if (newCard.type == CardClass.fine) {
        print('тип карты штраф');

        await PlayerState.addCardsPlayerDeck(
            roomName, newCard, 'fines', otherId);

        await GameState.removeCardGameDeck(
          roomName,
          newCard,
          'playingCardOnTable',
        );
        await Game.checkCountCardOnHand(
          context,
          roomName,
          'hand',
          Provider
              .of<CurrentPlayerState>(context, listen: false)
              .currentPlayer,
          myID,
          otherID,
        );
        await Game.cleanActCount(roomName);
        await Game.updatePlayOutCard(roomName, null);
        print('обнулили карту в штрафах');

        //заклинание
      } else if (newCard.type == CardClass.spell) {
        print('тип карты заклинание');
        // await Game.updateGameCardStatus(roomName, 'playOutSpell');
        await Game.changeGameStatus('playOutSpell', roomName);
      }


  }


  //проверяем можно ли разыгрывать карту после битвы тпру
  static Future<bool> checkCardOnTableForDraw(String roomName) async {
    try {
      List<CardModel> cardOnTable =
      await GameState.getDeck(roomName, 'playingCardOnTable');

      int countCard = cardOnTable.length;
      return countCard % 2 == 0 ? true : false;
    } catch (e) {
      print('Error fetching cards from table: $e');
      return false;
    }
  }


// сбросить карту в сброс
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

//уничтожить единорога соперника
     static Future<void> destroyUnicorn(
         CardModel? destroyCard,
         String roomName,
         String otherID,

         )async{
       await PlayerState.removeCardFromPlayerDeck(roomName, destroyCard!, 'stall', otherID);
       if(immortalUnicorns.contains(destroyCard.name)) {
         print('Имя карты "${destroyCard
             .name}" совпадает с одним из известных имен единорогов.');
         await PlayerState.addCardsPlayerDeck(
             roomName, destroyCard, 'hand', otherID);
       }else if(
         destroyCard.name != 'Baby'){
         print('убиваемый единорожек это не малыш');
         await GameState.updateWithNewCardGameDeck(
             roomName,
             destroyCard,
             'discardPile');
     // } else{
     //     await PlayerState.removeCardFromPlayerDeck(roomName, destroyCard!, 'stall', otherID);

       }
     }
     //уничтожить бонус
  static Future<void> destroyBonus(
      CardModel? destroyCard,
      String roomName,
      String otherID,
      )async{
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'bonuses',
        otherID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  // уничтожить штраф
  static Future<void> destroyFine(
      CardModel? destroyCard,
      String roomName,
      String otherID,

      )async{
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'fines',
        otherID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');

  }

//принести в жертву единорога
  static Future<void> sacrificeUnicorn(
  roomName,
  destroyCard,
  myID,
      )async{
    await PlayerState.removeCardFromPlayerDeck(roomName, destroyCard!, 'stall', myID);
    if(immortalUnicorns.contains(destroyCard.name)) {
      print('Имя карты "${destroyCard
          .name}" совпадает с одним из известных имен единорогов.');
      await PlayerState.addCardsPlayerDeck(
          roomName, destroyCard, 'hand', myID);
    }else if(
    destroyCard.name != 'Baby'){
      await GameState.updateWithNewCardGameDeck(
          roomName, destroyCard!, 'discardPile');
    } else{
      await PlayerState.removeCardFromPlayerDeck(roomName, destroyCard!, 'stall', myID);

    }
  }

  //принести в жертву бонус
  static Future<void> sacrificeBonus(
      CardModel? destroyCard,
      String roomName,
      String myID,

      )async{
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'bonuses',
        myID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  //принести в жертву  штраф
  static Future<void> sacrificeFines(
      CardModel? destroyCard,
      String roomName,
      String myID,

      )async{
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'fines',
        myID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }



  // static Future<void> _()async{}
  // static Future<void> _()async{}
}

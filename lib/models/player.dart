import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/screens/game_console.dart';
import '../services/current_player_provider.dart';
import '../services/game_data_provider.dart';
import 'card.dart';
import 'game.dart';
import 'game_state.dart';

class Player {

  static Future<void> playCard(
      BuildContext context,
    String roomName,
    String currentPlayer,
    CardModel newCard,
    String myID,
    String otherID,
      // Function(int) checkCount,
  ) async {

    // String currentPlayer = Provider
    //     .of<CurrentPlayerState>(context)
    //     .currentPlayer;
    final isMyTurn = currentPlayer == myID;
    print('текущий игрок на розыгрыше карт ${currentPlayer}');

    // добавляем карту на стол
    await GameState.updateWithNewCardGameDeck(
      roomName,
      newCard,
        'playingCardOnTable',
    );
    print('добавили карут на стол');
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        newCard,
        'hand',
        currentPlayer,
        // Provider
        //     .of<CurrentPlayerState>(context)
        //     .currentPlayer
    );
    print('удалили на руках');

// меняем текущего игрока
    await Game.nextPlayer(
      roomName,
      currentPlayer,
      // Provider
      //     .of<CurrentPlayerState>(context)
      //     .currentPlayer,
      myID,
      otherID,
    );
    print('старый текущий игрок ${currentPlayer}');

    // currentPlayer = await Game.currentPlayer(roomName);
    print('новый текущий игрок currentPlayer ${currentPlayer}');

    List<CardModel> handCards = await PlayerState.getPlayerDeck(roomName, 'hand',currentPlayer,
    ) as List<CardModel>;

print('мы на тпру');
print('myID $myID and ${currentPlayer}');

    if( isMyTurn){
     await PlayerState.checkTPRU(
          context,
          currentPlayer,
       // Provider
       //     .of<CurrentPlayerState>(context).currentPlayer,
          handCards,
          newCard,
          myID,
          otherID,
          roomName,
          // checkCount,
      );
    }
  }


  //забрать карту из сброса на руки
  static Future<void> takeCardPile(
      BuildContext context,
      String roomName,
      String currentPlayer,
      String typeGameDeck,
      String typePlayerDeck,
      int countTake,
      String myID,
      String otherID,
      CardModel newCards,
      )async {
//добавляем карту в руки игроку
    await PlayerState.addCardsPlayerDeck(
      roomName,
      newCards,
      'hand',
      'discardPile',
      currentPlayer,
    );
//удаляем карту из колоды сброса
    await GameState.removeCardGameDeck(
      roomName,
      newCards,
      'discardPile',
    );
//отправляем уведомление игроку2 о действия игрока1
    await Game.spentMessage(
      currentPlayer,
      roomName,
      'Selects a card from the discard pile',
    );
    // меняем текущего игрока, так как действие хода закончилось
    await Game.nextPlayer(
        roomName,
        currentPlayer,
        myID,
        otherID);
  }
    


      }


  //выложить тпру
//добавить как меняется текущий игрок
//и добавить отправку уведомления мол игрок отменяет карту
//передаем право отмены другому игроку, если отмены не было то меняем на другого игрока и продолжаем разыгрывать карту
//



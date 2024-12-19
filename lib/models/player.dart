import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';
import '../provider/current_player_provider.dart';
import 'card.dart';
import 'game.dart';
import 'game_state.dart';

class Player {
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
      DialogWindow.show(
          context, 'You can\'t play TPRU, choose another card', 'Notification');
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
        DialogWindow.show(context, 'Player $userNickname makes a move', 'Wait');
      }
    }
  }
}

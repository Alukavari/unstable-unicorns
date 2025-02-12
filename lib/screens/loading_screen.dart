import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/player_state.dart';
import 'game_board_screen.dart';

class LoadingScreen {

  static Future<void> navigateAndPerformActions(
      BuildContext context,
      String roomName,
      String playerID1,
      String userNickname,

      ) async {
    // Показать экран загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Выполнить асинхронные функции
    String? playerID2 = await Game.getPlayer(roomName);

    await Game.startGame(roomName, playerID1, playerID2!);
    await PlayerState.drawnCards(roomName, context, 5, playerID1, playerID2);
    // Закрыть экран загрузки
    Navigator.of(context).pop(); // Закрыть диалог загрузки

    // Перейти на новый экран
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GameBoardScreen(
              playersRoom: roomName,
              userNickname: userNickname,
            ),
      ),
    );
  }
}

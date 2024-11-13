import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class DB {
  //создание состояний комнаты
  Future<void> createRoomState(
      String roomName, Player player, bool gameStatus) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc('room');
    await roomRef.set({
      'gameStatus': gameStatus,
      'players':[],
      'currentTurn': player,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // начало игры с инициализацией состояния
  static Future<void> startGame(String roomName, String playerID1, String playerID2) async {
    await FirebaseFirestore.instance.collection(roomName).doc('room').set({
    'players': [playerID1, playerID2],
    'gameStatus': 'waiting', // ожидание начала игры
    'currentTurn': playerID1,
    'lastActive': FieldValue.serverTimestamp(),

    });

    final roomRef2 = FirebaseFirestore. instance.collection(roomName).doc('room');
    final roomData = await roomRef2.get();

    if ((!roomData.exists || roomData.data()?['players'] == null))return;
final players = List<String>.from(roomData.data()?['players']);

    await roomRef2.collection('GameState').doc('state').set({
      'deck': [],
      'discardPile': [],
      'playingCardOnTable': [],
    });

    for (String playerID in players) {
      await setPlayerState(roomName, playerID);
    }

    await roomRef2.update({
      'gameStatus': 'inProgress',
      'currentTurn': players.first,
    });
  }

//инициализация состояния игрока
  static Future<void> setPlayerState(String roomName, String playerId) async {
    final playerStateRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerId);

    await playerStateRef.set({
      'hand': [],
      'stall': [],
      'effects': [],
      'fines': [],
      'bonuses': [],
      'isOnline': true,
    });
  }

// смена хода

  Future<void> passTurn(String roomName) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc();
    final roomData = await roomRef.get();

    if (!roomData.exists || roomData.data()?['players']) ;
    final players = List<String>.from(roomData.data()?['players']);
    final currentTurn = roomData.data()?['currentTurn'];
    final currentIndex = players.indexOf(currentTurn);
    final nextIndex = (currentIndex + 1) % players.length;
    final nextPlayer = players[nextIndex];

    await roomRef.update({
      'currentTurn': nextPlayer,
      'lastActive': FieldValue.serverTimestamp(),
    });

    startTurnTimer(
        roomName, nextPlayer, 60); // Запускаем таймер для нового хода
  }

//таймер для каждого хода
  Future<void> startTurnTimer(
      String roomName, String player, int durationSeconds) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc();

    Future.delayed(Duration(seconds: durationSeconds), () async {
      final roomData = await roomRef.get();
      if (roomData.exists && roomData.data()?['currentTurn'] == player) {
        await passTurn(roomName);
      }
    });
  }
}

import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/services/current_player_provider.dart';

import 'card.dart';

class Game {
  // int currentPlayerIndex;
  // String gameStatus;
  // String gameWin;
  // String message;
  // String myID;
  // String otherID;
  //
  // Game({
  //   required this.currentPlayerIndex,
  //   required this.gameStatus,
  //   required this.gameWin,
  //   required this.message,
  //   required this.myID,
  //   required this.otherID,
  // });

  // start game
  static Future<void> startGame(
      String roomName, String playerID1, String playerID2) async {
    await FirebaseFirestore.instance.collection(roomName).doc('room').set({
      'players': [playerID1, playerID2],
      'gameStatus': 'waiting', // ожидание начала игры
      'currentTurn': playerID1,
      'lastActive': FieldValue.serverTimestamp(),
      'gameWin': '',
      'remainingTime': 60 // Сохраняйте оставшееся время
    });

    final roomRef2 =
    FirebaseFirestore.instance.collection(roomName).doc('room');
    final roomData = await roomRef2.get();

    if ((!roomData.exists || roomData.data()?['players'] == null)) return;
    final players = List<String>.from(roomData.data()?['players']);

    await roomRef2.collection('GameState').doc('state').set({
      'deck': [],
      'discardPile': [],
      'playingCardOnTable': [],
    });

    for (String playerID in players) {
      await PlayerState.setPlayerState(roomName, playerID);
    }

    await roomRef2.update({
      'gameStatus': 'inProcess',
      'currentTurn': players.first,
    });

    await roomRef2.collection('message').doc('action').set({
      'actionType': '',
      'playerId': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  //get current player
  static Future<String> currentPlayer(String roomName) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc('room');

    final roomData = await roomRef.get();
    if (!roomData.exists || roomData.data()?['currentTurn'] == null) {
      return 'not found';
    }
    String currentTurn = roomData.data()?['currentTurn'];
    return currentTurn;
  }

  // check bonuses for count act


// update current player
  static Future<void> nextPlayer(
    String roomName,
    String currentPlayer,
    String myID,
    String otherID,
  ) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc('room');

    String nextPlayer = (currentPlayer == myID) ? otherID : myID;

    await roomRef.update({
      'currentTurn': nextPlayer,
    });
  }

  static Future<void> spentMessage(
      String currentPlayer,
      String roomName,
      String actionType
      ) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('message')
        .doc('action')
        .update({
      'actionType': actionType,
      'playerId': currentPlayer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

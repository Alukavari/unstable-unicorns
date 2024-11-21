import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/card.dart';
import 'package:unstable_unicorns/models/player.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';

import 'deck.dart';
import 'game_state.dart';

enum GameStatus {
  waiting,
  inProcess,
  finished,
}

class Game {
  List<Player> players;
  int currentPlayerIndex;
  GameStatus gameStatus;
  GameState gameState;

  Game(this.gameStatus,
      {required this.players,
      required this.gameState,
      required this.currentPlayerIndex});

  static Future<void> startGame(
      String roomName, String playerID1, String playerID2) async {
    await FirebaseFirestore.instance.collection(roomName).doc('room').set({
      'players': [playerID1, playerID2],
      'gameStatus': 'waiting', // ожидание начала игры
      'currentTurn': playerID1,
      'lastActive': FieldValue.serverTimestamp(),
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

  //get current player
  static Future<String> currentPlayer (String roomName)async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room');

    final roomData = await roomRef.get();
    if(!roomData.exists || roomData.data()?['currentTurn'] == null){
      return 'not found';
    }
    String currentTurn = roomData.data()?['currentTurn'];
    return currentTurn;
    }

// puss turn
 static Future<void> passTurn(String roomName) async {

    final roomRef = FirebaseFirestore.instance.collection(roomName).doc('room');
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
  static Future<void> startTurnTimer(
      String roomName, String player, int durationSeconds) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc();

    Future.delayed(Duration(seconds: durationSeconds), () async {
      final roomData = await roomRef.get();
      if (roomData.exists && roomData.data()?['currentTurn'] == player) {
        await passTurn(roomName);
      }
    });
  }

  //раздача карт
  static Future<void> drawnCards(
      String roomName,
      BuildContext context,
      List<CardModel> babyDeck,
      List<CardModel> cards,
      int count,
      String playerID1,
      String playerID2) async {
    final deck = cards;

    List<CardModel> babyCards = List.from(babyDeck);

    List<CardModel> player1CardsOnHand = [];
    List<CardModel> player2CardsOnHand = [];

    List<CardModel> player1CardsOnTable = [];
    List<CardModel> player2CardsOnTable = [];

    //добавляем 1 тпру на руки
    player1CardsOnHand.add(CardModel(
        'ТПРУ',
        'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
        CardClass.tpru,
        'assets/13tpru.png',
        '13tpru'));
    player2CardsOnHand.add(CardModel(
        'ТПРУ',
        'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
        CardClass.tpru,
        'assets/14tpru.png',
        '14tpru'));

    // добавяем малыша на стол
    Random random = Random();
    int babyIndex1 = random.nextInt(babyCards.length);
    player1CardsOnTable.add(babyCards[babyIndex1]);
    babyCards.removeAt(babyIndex1);

    int babyIndex2 = random.nextInt(babyCards.length);
    player2CardsOnTable.add(babyCards[babyIndex2]);
    babyCards.removeAt(babyIndex2);

    // Вытаскиваем по 6 случайных карт из основной колоды для каждого игрока
    if (deck.length >= count) {
      for (int i = 0; i < count; i++) {

        int randomIndex1 = random.nextInt(deck.length);
        player1CardsOnHand.add(deck[randomIndex1]);
        deck.removeAt(randomIndex1);

        int randomIndex2 = random.nextInt(deck.length);
        player2CardsOnHand.add(deck[randomIndex2]);
        deck.removeAt(randomIndex2);
      }
      // обновить колоды в firestore

      try {
        await Deck.updateDeck(roomName, deck);
        await Deck.updatePlayerDeck(
            roomName, player1CardsOnTable, 'stall', playerID1);
        await Deck.updatePlayerDeck(
            roomName, player2CardsOnTable, 'stall', playerID2);

        await Deck.updatePlayerDeck(
            roomName, player1CardsOnHand, 'hand', playerID1);
        await Deck.updatePlayerDeck(
            roomName, player2CardsOnHand, 'hand', playerID2);
      } catch (e) {
        print('Error in updating decks: $e');
      }
    } else {
      print('Not enough cards in deck to draw: ${deck.length} available');
    }
  }
}

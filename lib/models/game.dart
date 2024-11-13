import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/card.dart';
import 'package:unstable_unicorns/models/player.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';

import 'deck.dart';
import 'game_state.dart';
enum GameStatus{
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
      {
        required this.players,
        required this.gameState,
        required this.currentPlayerIndex});

  victoryCondition(List<Card> stall, Player player) {
    if (stall.length >= 7) {
      player.playerWinOrNot = true;
    } else {
      player.playerWinOrNot = false;
    }
  }

  // void movePossibility(BuildContext context, List<Card> deck, Player player, Game game, int count) {
  //   if (deck.length >= count) {
  //   } else {
  //     DialogWindow.show(context, 'Внимание!',
  //         'Недостаточно карт для хода, игра окончена');
  //   }
  // }

  void startGame(Player player1, Player player2, Game game) {
    Deck deck = Deck();
    deck.createDeck(); // создание колоды с картами
    deck.shuffle(); //перемешали колоду

  }

  //раздача карт
  Future<List<CardModel>> drawnCards(BuildContext context, List<CardModel> deck,
      int count,
      Player player) async {
    List<CardModel> drawCards = [];

    if (deck.length < count) {
      await DialogWindow.show(context, 'Внимание!',
          'Недостаточно карт для хода, игра окончена');
    } else {
      for (int i = 0; i < count; i++) {
        drawCards.add(deck.removeLast());

        // обновить колоду в firestore
      }
    }
    return drawCards;
  }
}


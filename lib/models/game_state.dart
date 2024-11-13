import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/player_state.dart';

import 'card.dart';

class GameState {
  List<CardModel> deck; // Колода карт
  List<CardModel> discardPile; // Сброс карт
  List<PlayerState> playersState; // Состояния игроков
  List<CardModel> playingCardOnTable;
  List<Action> action;

  GameState(
      {required this.deck,
      required this.discardPile,
      required this.playersState,
      required this.playingCardOnTable,
      required this.action});
}

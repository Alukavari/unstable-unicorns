import 'package:flutter/material.dart';

import 'card.dart';

class Player {
  String playerId;
  String? userNickname;
  bool playerWinOrNot = false;


  Player({
    required this.userNickname,
    required this.playerId});


  // Метод для вытаскивания карты из колоды
  CardModel drawCard(List<CardModel> deck) {
    if (deck.isNotEmpty) {
      return deck.removeLast(); // Вытаскиваем верхнюю карту
    }
    throw Exception('Колода пуста');
  }


  // Метод для добавления карты обратно в колоду
   addCard(CardModel card) {
  }


  resetCard() {}

  putCardInTheStall() {}

  cancelMove() {}

  destroyCard() {}

  stealCard() {}

  playCard() {}

  exchangeUnicorn() {}

}
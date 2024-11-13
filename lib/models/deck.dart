import 'package:flutter/material.dart';

import 'card.dart';

class Deck{

  List<CardModel> cards;

  Deck(): cards = [];

  void createDeck() {
    cards.add(CardModel('ХВАТЬ-ХВАТЬ',
        'В начале своего хода можешь сбросить 1 карту, а затем взять 1 карту',
        CardClass.bonus, 'assets/1b.png', '1b'));
    cards.add(CardModel('ХВАТЬ-ХВАТЬ',
        'В начале своего хода можешь сбросить 1 карту, а затем взять 1 карту',
        CardClass.bonus, 'assets/2b.png', '2b'));
    cards.add(CardModel('ХВАТЬ-ХВАТЬ',
        'В начале своего хода можешь сбросить 1 карту, а затем взять 1 карту',
        CardClass.bonus, 'assets/3b.png', '3b'));

    cards.add(CardModel('АРТАБСТОЙЛО',
        ' В начале своего хода можешь сбросить 2 карты, а затем уничтожить 1 единорожка',
        CardClass.bonus, 'assets/4b.png', '4b'));
    cards.add(CardModel('АРТАБСТОЙЛО',
        ' В начале своего хода можешь сбросить 2 карты, а затем уничтожить 1 единорожка',
        CardClass.bonus, 'assets/5b.png', '5b'));
    cards.add(CardModel('АРТАБСТОЙЛО',
        ' В начале своего хода можешь сбросить 2 карты, а затем уничтожить 1 единорожка',
        CardClass.bonus, 'assets/6b.png', '6b'));

    cards.add(CardModel('ДИСКОБОМБА',
        'В начале своего хода можешь принести в жертву 1 карту? а затем уничтожить 1 карту',
        CardClass.bonus, 'assets/7b.png', '7b'));
    cards.add(CardModel('ДИСКОБОМБА',
        'В начале своего хода можешь принести в жертву 1 карту? а затем уничтожить 1 карту',
        CardClass.bonus, 'assets/8b.png', '8b'));
    cards.add(CardModel('ДИСКОБОМБА',
        'В начале своего хода можешь принести в жертву 1 карту? а затем уничтожить 1 карту',
        CardClass.bonus, 'assets/9b.png', '9b'));
  }

  void shuffle(){
    cards.shuffle();
  }
}
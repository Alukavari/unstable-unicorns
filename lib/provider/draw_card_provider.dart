import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/card.dart';

import '../models/deck.dart';

class DrawCardProvider with ChangeNotifier {
  CardModel? _drawCard ;

  CardModel? get drawCard => _drawCard;

  void updateDrawCard(CardModel? newCard) {
    if (_drawCard != newCard) {
      _drawCard = newCard;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }
}
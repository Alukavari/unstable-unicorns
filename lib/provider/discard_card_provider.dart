import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/card.dart';

import '../models/deck.dart';

class DiscardCardProvider with ChangeNotifier {
  int _discardCard = 0 ;

  int get discardCard => _discardCard;

  void updateDiscardCard(int newCard) {
    if (_discardCard != newCard) {
      _discardCard = newCard;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }

  void decreaseDiscardCard() {
    _discardCard--;
    notifyListeners();
  }
}
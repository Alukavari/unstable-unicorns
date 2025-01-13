import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/card.dart';

import '../models/deck.dart';

class PlayOutCardProvider with ChangeNotifier {
  CardModel? _playOutCard ;

  CardModel? get playOutCard => _playOutCard;

  void updatePlayOutCard(CardModel? newCard) {
    print('обновили игральную карту через провайдер');
    if (_playOutCard != newCard) {
      _playOutCard = newCard;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }

}
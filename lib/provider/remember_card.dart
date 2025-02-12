import 'package:flutter/material.dart';
import '../models/card.dart';

class RememberCard with ChangeNotifier {
CardModel? _playCard;

CardModel? get playCard => _playCard;

void updateCard(CardModel? newPlayCard) {
    if (playCard != newPlayCard) {
      _playCard = newPlayCard;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }

}
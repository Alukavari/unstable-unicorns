import 'package:flutter/material.dart';

class GamePlayOutCardStatus with ChangeNotifier {
  String _playOutCardStatus = '';

  String get playOutCardStatus => _playOutCardStatus;

  void updateCardEffects(String newStatusCard) {
    if (_playOutCardStatus != newStatusCard) {
      _playOutCardStatus = newStatusCard;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }

}
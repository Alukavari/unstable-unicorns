import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentPlayerState with ChangeNotifier {
  String _currentPlayer = '';

  String get currentPlayer => _currentPlayer;

  void updateCurrentPlayer(String newPlayer) {
    if (_currentPlayer != newPlayer) {
      _currentPlayer = newPlayer;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }
}
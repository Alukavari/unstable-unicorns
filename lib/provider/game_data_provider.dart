import 'package:flutter/material.dart';


class GameDataProvider extends ChangeNotifier {
  int _actCount = 0;
  int get actCount => _actCount;

  void updateActCount(int newActCount) {
    if (_actCount != newActCount) {
      _actCount = newActCount;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }

  // void incrementActCount() {
  //   print('добавляем +1');
  //   _actCount++;
  //   notifyListeners();
  // }
  //
  // void cleanCount(){
  //   print('чистм коунт');
  //   _actCount = 0;
  //   notifyListeners();
  // }
}
import 'package:flutter/material.dart';


class ProgressCheckProvider with ChangeNotifier {
  int _check = 0;

  int get check => _check;

  void updateCheck(int newCount) {
    if (_check != newCount) {
      _check = newCount;
      notifyListeners(); // Уведомляем слушателей о том, что состояние изменилось
    }
  }


}



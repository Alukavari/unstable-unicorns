import 'package:flutter/material.dart';


class GameDataProvider extends ChangeNotifier {
  int _actCount = 0;
  int get actCount => _actCount;


  void incrementActCount() {
    _actCount++;
    notifyListeners();
  }

  void cleanCount(){
    _actCount = 0;
  }
}
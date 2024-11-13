import 'package:flutter/material.dart';

import 'card.dart';

class PlayerState {
  String playerId; // ID игрока
  List<CardModel> hand; // Карты в руке
  List<CardModel> stall; // карты в стойле
  List<CardModel> fines; // штрафы на столе
  List<CardModel> bonuses;// бонусы на столе
  Map<String, dynamic> effects; // Текущие эффекты или ограничения на игрока

  PlayerState({
    required this.playerId,
    required this.hand,
    required this.effects,
    required this.stall,
    required this.fines,
    required this.bonuses,

  });
}
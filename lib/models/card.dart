import 'dart:math';

import 'deck.dart';

enum CardClass {
  bonus,
  unicorn,
  spell,
  fine,
  tpru,
  baby,
}

class CardModel {
  final String name;
  final String description;
  final CardClass type;
  final String imageUrl;
  final String id;


  CardModel(
      this.name,
      this.description,
      this.type,
      this.imageUrl,
      this.id,
      );

  // Метод для преобразования карточки в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'id': id,

    };
  }

  // Метод для создания карточки из Map
  static CardModel fromMap(Map<String, dynamic> map) {
    return CardModel(
      map['name'] as String,
      map['description'] as String,
      CardClass.values.firstWhere((e) => e.toString().split('.').last == map['type']),
      map['imageUrl'] as String,
      map['id'] as String,

    );
  }




}


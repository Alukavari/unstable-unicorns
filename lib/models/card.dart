import 'dart:math';

import 'deck.dart';

enum CardClass {
  bonus,
  unicorn,
  spell,
  fine,
  tpru,
}

class CardModel {
  final String id;
  final String name;
  final String description;
  final CardClass type;
  final String imageUrl;
  final bool activated = true;

  CardModel(this.name,
      this.description,
      this.type,
      this.imageUrl,
      this.id);

//преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'imageUrl': imageUrl,
      'activated': activated,

    };
  }
}


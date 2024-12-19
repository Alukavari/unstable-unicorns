import 'dart:math';

import 'package:flutter/material.dart';

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

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return other is CardModel && other.id == id; // Сравниваем по id
  // }
  //
  // @override
  // int get hashCode => id.hashCode; // Используем id для хеширования

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


  static List<CardModel> splitDeckWithoutType (List<CardModel> deck) {
    List<CardClass> desiredTypes = [
      CardClass.unicorn,
      CardClass.bonus,
      CardClass.spell,
      CardClass.fine,
    ];

    List<CardModel> remainingCards = deck.where((card) =>
    !desiredTypes.contains(card.type)).toList();
    return remainingCards;
  }


  static CardModel splitDeckWithType (List<CardModel> deck) {
    List<CardClass> desiredTypes = [
      CardClass.unicorn,
      CardClass.bonus,
      CardClass.fine,
      CardClass.spell,
    ];

    CardModel withFilter = deck.firstWhere((card) =>
    desiredTypes.contains(card.type));

    return withFilter;
  }


}


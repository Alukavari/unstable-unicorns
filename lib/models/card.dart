import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/widgets/scroll_for_game.dart';

import 'deck.dart';
import 'game.dart';

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

  
  static Future<void> drawnUnicorn(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,

      )async{
    // if(card?.name == 'ЛАМАРОГ'){
      print('мы в ламароге разыгрываемся');
      await Game.changeGameStatus('drawnLamarog', roomName);
      String currentPlayer = Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer;
      await PlayerState.addCardsPlayerDeck(roomName, card!, 'stall', currentPlayer);
    await GameState.removeCardGameDeck(roomName, card!, 'playingCardOnTable');

      if (Provider.of<ProgressCheckProvider>(context, listen: false).check == 2
      ){
        await Game.changeGameStatus('inProcess', roomName);
        print('карат разыграна, в ламароге на финале');
await Game.updateCardAction(roomName, 0);
print('сколько в картах активности обнуления');

// await Game.cleanActCount(roomName);
      }
  }

  static Future<void> drawnSpell(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,

      )async{}

  static Future<void> drawnFins(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,

      )async{}

  static Future<void> drawnBonuses(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,

      )async{}


}


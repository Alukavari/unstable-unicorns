import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/deckOfCards.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player_state.dart';

import '../const/const.dart';
import '../provider/current_player_provider.dart';
import '../provider/discard_card_provider.dart';
import '../services/dialog/dialog_window.dart';
import 'card.dart';
import 'game.dart';

class CheckPossibility {
//проверка наичия радужной ауры
  static Future<bool> checkRainbowAura(
    String roomName,
    String otherID,
    BuildContext context,
  ) async {
    List<CardModel>? deckBonuses =
        await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
    bool containsCard =
        deckBonuses?.any((card) => card.name == 'РАДУЖНАЯ АУРА') ?? false;
    print('есть ли у нас бонус радужной ауры $containsCard');

    return containsCard;
  }

  static Future<bool> checkCat(
    String roomName,
    String otherID,
  ) async {
    List<CardModel>? deckBonuses =
        await PlayerState.getPlayerDeck(roomName, 'stall', otherID);
    bool containsCard =
        deckBonuses?.any((card) => card.name == 'ВОЛШЕБНЫЙ КОТОРОГ') ?? false;
    int? deckCount = deckBonuses?.length;

    bool isEven = containsCard && deckCount == 1 ? false : true;
    return isEven;
  }

//проверка достаточно ли карт для принесения жертвы 1 карта
  static Future<bool> checkHaveCardForSacrifice(
    String roomName,
    String myID,
  ) async {
    List<CardModel> allMyCard = [];
    List<CardModel>? myStall =
        await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    if (myStall!.isNotEmpty) {
      allMyCard.addAll(myStall);
    }
    List<CardModel>? myBonus =
        await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    if (myBonus!.isNotEmpty) {
      allMyCard.addAll(myBonus);
    }
    List<CardModel>? myFines =
        await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    if (myFines!.isNotEmpty) {
      allMyCard.addAll(myFines);
    }

    bool isEven = allMyCard.isNotEmpty;
    return isEven;
  }

  //достаточно ли карт для уничтожегия заданного количества карт
  static Future<bool> checkHaveCardForDestroy(
    BuildContext context,
    String roomName,
    String otherID,
    int countDestroy,
  ) async {
    List<CardModel> allOtherCard = [];
    //проверка наличия радужной ауры
    bool isEven = await checkRainbowAura(roomName, otherID, context);

    if (!isEven) {
      print('net raduznoi auri');
      List<CardModel>? otherStall =
          await PlayerState.getPlayerDeck(roomName, 'stall', otherID);
      if (otherStall!.isNotEmpty) {
        allOtherCard.addAll(otherStall);
      }
    }

    List<CardModel>? otherBonus =
        await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
    if (otherBonus!.isNotEmpty) {
      allOtherCard.addAll(otherBonus);
    }
    List<CardModel>? otherFines =
        await PlayerState.getPlayerDeck(roomName, 'fines', otherID);
    if (otherFines!.isNotEmpty) {
      allOtherCard.addAll(otherFines);
    }
    print(
        'сколько карт при проверке на возса возможность уничтожить карту ${allOtherCard.length}');
    bool isEven2 =
        allOtherCard.isNotEmpty && allOtherCard.length >= countDestroy;
    print(
        'какой бул в проверке на нужное количество уничтожени  карт $isEven2');
    return isEven2;
  }

  //проверка возможности уничтожения единорожков в чужом стойле
  static Future<bool> checkHaveUnicornForDestroy(
    BuildContext context,
    String roomName,
    String otherID,
  ) async {

    List<CardModel>? otherFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', otherID);

    bool isEven2 = otherFines?.any((card)=> card.name == 'ПАНДЕЦ') ?? false;
    print('есть ли пандец $isEven2');

    if(isEven2){
      return true;
    }


    bool isEven = await checkRainbowAura(roomName, otherID, context);

    if (!isEven) {
      print('net raduznoi auri');
      List<CardModel>? otherStall =
          await PlayerState.getPlayerDeck(roomName, 'stall', otherID);
      print('allOtherCard ${otherStall?.length}');

      if (otherStall!.isNotEmpty) {
        return true;
      }
    }
    print('allOtherCard 0');
    return false;
  }

  static Future<bool> checkHaveUnicornForSacrifice(
    BuildContext context,
    String roomName,
    String myID,
  ) async {
    List<CardModel>? otherFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);

    bool isEven2 = otherFines?.any((card)=> card.name == 'ПАНДЕЦ') ?? false;

    if(isEven2){
      return true;
    }

    List<CardModel>? otherStall =
        await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    print('allOtherCard ${otherStall?.length}');

    bool isEven = otherStall!.isNotEmpty ? true : false;
    return isEven;
  }

  //проверка,есть ли бонусы или штрафы для перемещения
  static Future<bool> checkHaveFinesOrBonuses(
    String roomName,
    String myID,
    String otherID,
  ) async {
    // Проверка бонусов и штрафов для моего ID
    for (String type in ['bonuses', 'fines']) {
      List<CardModel>? myCards =
          await PlayerState.getPlayerDeck(roomName, type, myID);
      if (myCards != null && myCards.isNotEmpty) {
        return true;
      }

      List<CardModel>? otherCards =
          await PlayerState.getPlayerDeck(roomName, type, otherID);
      if (otherCards != null && otherCards.isNotEmpty) {
        return true;
      }
    }

    // Если ни в одной из колод данных не найдено, возвращаем false
    return false;
  }

  static Future<bool> checkHaveCardOnPD(
    String roomName,
    String playerID,
    String typeDeck,
    int count,
  ) async {
    List<CardModel>? cardOnHand =
        await PlayerState.getPlayerDeck(roomName, typeDeck, playerID);

    bool isEven = cardOnHand!.length >= count;
    return isEven;
  }

// проверка нужного количества карт в колоде игры
  static Future<bool> checkHaveCardOnDeck(
    String roomName,
    String typeDeck,
    int count,
  ) async {
    List<CardModel>? cardOnDeck = await GameState.getDeck(roomName, typeDeck);

    bool isEven = cardOnDeck!.length >= count;
    return isEven;
  }

  static Future<bool> checkHaveCardOnDeckSpecificType(
    String roomName,
    String typeDeck,
    CardClass type,
    int count,
  ) async {
    List<CardModel>? deck = [];
    List<CardModel>? cardOnDeck = await GameState.getDeck(roomName, typeDeck);

    deck = cardOnDeck.where((card) => card.type == type).toList();
    print('сколько единорогов в колоде игры ${cardOnDeck.length}');

    bool isEven = deck.length >= count;
    return isEven;
  }

//есть ли на столе хотя бы каких либо типов у обоих игроков
  static Future<bool> checkHaveCardOnStall(
    String roomName,
    String myID,
    String otherID,
  ) async {
    List<CardModel>? cardOnMyStall =
        await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    List<CardModel>? cardOnOtherStall =
        await PlayerState.getPlayerDeck(roomName, 'stall', otherID);

    if (cardOnMyStall!.isEmpty) {
      cardOnMyStall =
          await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
      if (cardOnMyStall!.isEmpty) {
        cardOnMyStall =
            await PlayerState.getPlayerDeck(roomName, 'fines', myID);
        if (cardOnMyStall!.isEmpty) {
          return false;
        }
      }
    } else if (cardOnOtherStall!.isEmpty) {
      cardOnOtherStall =
          await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
      if (cardOnOtherStall!.isEmpty) {
        cardOnOtherStall =
            await PlayerState.getPlayerDeck(roomName, 'fines', otherID);
        if (cardOnOtherStall!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  static Future<bool> checkHaveMiniStall(
      BuildContext context,
    String roomName,
    String myID,
  ) async {
    String? currentPlayer =
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;
    List<CardModel>? fines = await PlayerState.getPlayerDeck(
      roomName,
      'fines',
      currentPlayer,
    );

    bool isEven = fines?.any((card)=> card.name == 'МИНИ-СТОЙЛО') ?? false;
    bool isEven1 = fines?.any((card)=> card.name == 'ПАНДЕЦ') ?? false;

    if(isEven && !isEven1){
      print('mini stall yas');
      return true;
    } else{
      print('mini stall no');
      return false;
    }

  }


  static Future<bool> checkHavePandec(
    String roomName,
    String playerID,
  ) async {

    List<CardModel>? fines = await PlayerState.getPlayerDeck(
      roomName,
      'fines',
      playerID,
    );
    bool isEven = fines?.any((card)=> card.name == 'ПАНДЕЦ') ?? false;
    print('есть ли пандец $isEven');

    if(!isEven){
     return true;
   }
   return false;
  }

  static Future<bool> checkHaveSun(
    String roomName,
    String playerID,
  ) async {

    List<CardModel>? fines = await PlayerState.getPlayerDeck(
      roomName,
      'fines',
      playerID,
    );
    bool isEven = fines?.any((card)=> card.name == 'СЛЕПЯЩИЙ СВЕТ') ?? false;
    print('есть ли СЛЕПЯЩИЙ СВЕТ $isEven');

    if(!isEven){
     return true;
   }
   return false;
  }

  static Future<bool> checkHaveSuck(
    String roomName,
    String playerID,
  ) async {

    List<CardModel>? fines = await PlayerState.getPlayerDeck(
      roomName,
      'fines',
      playerID,
    );
    bool isEven = fines?.any((card)=> card.name == 'ОТСТОЙЛО') ?? false;
    print('есть ли ОТСТОЙЛО $isEven');

    if(!isEven){
     return true;
   }
   return false;
  }


  static Future<bool> checkHaveWire(
    String roomName,
    String myID,
  ) async {
    List<CardModel>? fines = await PlayerState.getPlayerDeck(
      roomName,
      'fines',
      // currentPlayer,
        myID,
    );

    bool isEven = fines?.any((card) => card.name == 'КОЛЮЧАЯ ПРОВОЛКА') ??
        false;
    return isEven;
  }

  static Future<bool> checkHaveJump(
      BuildContext context,
    String roomName,
    String currentPlayer,
  ) async {

    // если true то 1 ход если false то 2

    List<CardModel>? bonuses = await PlayerState.getPlayerDeck(
        roomName, 'bonuses', currentPlayer);
    List<CardModel>? fines = await PlayerState.getPlayerDeck(
        roomName, 'fines', currentPlayer);
    List<CardModel>? effects = await PlayerState.getPlayerDeck(
      roomName, 'effects', Provider
        .of<CurrentPlayerState>(context, listen: false)
        .currentPlayer,);
    bool isEvenSuck = fines?.any((card) => card.name == 'ОТСТОЙЛО') ?? false;

    bool isEvenJump = bonuses?.any((card) => card.name == 'ПРЫГ-СКОК') ?? false;
    print('есть ли карта ПРЫГ-СКОК $isEvenJump ');
    bool isEvenEffects = effects?.any((card) => card.name == 'ПРЫГ-СКОК') ?? false;
    print('есть ли карта in effects $isEvenEffects ');

    if (isEvenSuck || (!isEvenJump || isEvenEffects)) {
      return true;
    } else {
      return false;
    }
    }

    }


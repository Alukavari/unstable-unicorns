import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/services/dialog/dialog_for_game.dart';
import 'package:unstable_unicorns/services/dialog/dialog_window.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_destroy.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_game.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_sacrifice.dart';

import '../const/deckOfCards.dart';
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

  static Future<bool> checkRainbowAura(
      String roomName,
      String otherID,
      BuildContext context,
      ) async{
  List<CardModel>? deckBonuses = await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
  bool containsCard = deckBonuses?.any((card) => card.name == 'РАДУЖНАЯ АУРА') ?? false;
  print('есть ли у нас бонус радужной ауры $containsCard');

  return containsCard;
  }

  static Future<bool> checkHaveCardForSacrifice(
      BuildContext context,
      String roomName,
      String myID,
      )async{
    List<CardModel> allMyCard = [];
    List<CardModel>? myStall = await PlayerState.getPlayerDeck(
        roomName, 'stall', myID);
    if (myStall!.isNotEmpty) {
      allMyCard.addAll(myStall);
    }
    List<CardModel>? myBonus = await PlayerState.getPlayerDeck(
        roomName, 'bonuses', myID);
    if (myBonus!.isNotEmpty) {
      allMyCard.addAll(myBonus);
    }
    List<CardModel>? myFines = await PlayerState.getPlayerDeck(
        roomName, 'fines', myID);
    if (myFines!.isNotEmpty) {
      allMyCard.addAll(myFines);
    }

    bool isEven = allMyCard.isNotEmpty;
    return isEven;
  }

  static Future<bool> checkHaveCardForDestroy(
      BuildContext context,
      String roomName,
      String otherID,
      )async{

    List<CardModel> allOtherCard = [];
    bool isEven = await checkRainbowAura(roomName, otherID, context);

    if(!isEven){
      print('net raduznoi auri');
      List<CardModel>? otherStall = await PlayerState.getPlayerDeck(
          roomName, 'stall', otherID);
      if (otherStall!.isNotEmpty) {
        allOtherCard.addAll(otherStall);
    }
    }
    List<CardModel>? otherBonus = await PlayerState.getPlayerDeck(
        roomName, 'bonuses', otherID);
    if (otherBonus!.isNotEmpty) {
      allOtherCard.addAll(otherBonus);
    }
    List<CardModel>? otherFines = await PlayerState.getPlayerDeck(
        roomName, 'fines', otherID);
    if (otherFines!.isNotEmpty) {
      allOtherCard.addAll(otherFines);
    }

bool isEven2 = allOtherCard.isNotEmpty;
    return isEven2;

  }

  static Future<bool> checkHaveUnicornForDestroy(
      BuildContext context,
      String roomName,
      String otherID,
      )async{

    List<CardModel> allOtherCard = [];
    bool isEven = await checkRainbowAura(roomName, otherID, context);

    if(!isEven){
      print('net raduznoi auri');
      List<CardModel>? otherStall = await PlayerState.getPlayerDeck(
          roomName, 'stall', otherID);
      if (otherStall!.isNotEmpty) {
        allOtherCard.addAll(otherStall);
      }
    }

    bool isEven2 = allOtherCard.isNotEmpty;
    return isEven2;

  }



// заклинание два по цене одного
  static Future<void> twoForThePriceOfOne(
      BuildContext context,
  String roomName,
  String myID,
  String otherID,
      )async {
    print('мы в два по цене одного');
    print('какой дискрипшин в два по цене одного1 ${cardDescription['ДВА ПО ЦЕНЕ ОДНОГО1']!}');
    print('какой дискрипшин в два по цене одного2 ${cardDescription['ДВА ПО ЦЕНЕ ОДНОГО2']!}');

    CardModel? name1 = await Game.getPlayOutCard(roomName);
    String name = name1!.name;
    print('пытаемся получить значение в два по цене одного разыгырваемая карта $name');

    List<CardModel> allMyCard = [];
      List<CardModel>? myStall = await PlayerState.getPlayerDeck(
          roomName, 'stall', myID);
      if (myStall!.isNotEmpty) {
        allMyCard.addAll(myStall);
      }
      List<CardModel>? myBonus = await PlayerState.getPlayerDeck(
          roomName, 'bonuses', myID);
      if (myBonus!.isNotEmpty) {
        allMyCard.addAll(myBonus);
      }
      List<CardModel>? myFines = await PlayerState.getPlayerDeck(
          roomName, 'fines', myID);
      if (myFines!.isNotEmpty) {
        allMyCard.addAll(myFines);
      }
      //проверяем есть ли бонус радужная аура
    List<CardModel> allOtherCard = [];
    bool isEven = await checkRainbowAura(roomName, otherID, context);
      if(!isEven){
        List<CardModel>? otherStall = await PlayerState.getPlayerDeck(
            roomName, 'stall', otherID);
        if (otherStall!.isNotEmpty) {
          allOtherCard.addAll(otherStall);
      }
        }

        List<CardModel>? otherBonus = await PlayerState.getPlayerDeck(
            roomName, 'bonuses', otherID);
        if (otherBonus!.isNotEmpty) {
          allOtherCard.addAll(otherBonus);

        }
        List<CardModel>? otherFines = await PlayerState.getPlayerDeck(
            roomName, 'fines', otherID);
        if (otherFines!.isNotEmpty) {
          allOtherCard.addAll(otherFines);

        }

      if (myID == Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer) {
        await DialogForGame.show(
            context,
            cardDescription['ДВА ПО ЦЕНЕ ОДНОГО1']!,
            roomName,
            allMyCard,
            myID,
            otherID,
            ScrollForSacrifice(
                cards: allMyCard,
                roomName: roomName,
                myID: myID,
                countDiscard: 1));

        await DialogForGame.show(
          context,
          cardDescription['ДВА ПО ЦЕНЕ ОДНОГО2']!,
          roomName,
          allOtherCard,
          myID,
          otherID,
          ScrollForDestroy(
              cards: allOtherCard,
              roomName: roomName,
              myID: myID,
              otherID: otherID,
              countDestroy: 2),
        );
      }

    }


  static Future<void> _()async{}

//заклинания единорожий яд
  static Future<void> spellUnicornPoison(
      String roomName,
      String myID,
      String otherID,
      CardModel? card,
      BuildContext context,
      )async {
//текущий игрок
  print('мы на розыгрыше единорожьего яда');

      String description = cardDescription['ЕДИНОРОЖИЙ ЯД'] ?? '';

      List<CardModel>? deck = await PlayerState.getPlayerDeck(
          roomName, 'stall', otherID);
      bool containsCatUnicorn = deck?.any((card) => card.name == 'ВОЛШЕБНЫЙ КОТОРОГ') ??
          false;
      print('есть ли у нас которог $containsCatUnicorn');
      if (containsCatUnicorn) {
        print('до удаления ${deck?.length}');
        CardModel? card = deck?.firstWhere((card) => card.name == 'ВОЛШЕБНЫЙ КОТОРОГ');
        deck?.remove(card);
        print('после удаления у диалога ${deck?.length}');

        DialogForGame.show(
            context,
            description,
            roomName,
            deck,
            myID,
            otherID,
            ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
                onCardTap:
                    (BuildContext context, CardModel? card) async{
              await Player.destroyUnicorn(card, roomName, otherID);
            },
            ),
        );
      } else {
        DialogForGame.show(
            context,
            description,
            roomName,
            deck,
            myID,
            otherID,
          ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
            onCardTap:
                (BuildContext context, CardModel? card) async{
                  await Player.destroyUnicorn(card, roomName, otherID);
            },
          ),
        );
      }
  }

  
  static Future<void> playOutUnicorn(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,

      )async{
      print('разыгрываем единорога');
      String currentPlayer = Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer;

      await PlayerState.addCardsPlayerDeck(roomName, card!, 'stall', currentPlayer);
    await GameState.removeCardGameDeck(roomName, card, 'playingCardOnTable');
    print('мы на розыгрыше юникорнов перед чеккоунткардонхэнд');
      await Game.checkCountCardOnHand(
        context,
        roomName,
        'hand',
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer,
        myID,
        otherID,
      );
// await Game.cleanActCount(roomName);
  }

  static Future<void> playOutSpell(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,
      )async{
    CardModel? card = await Game.getPlayOutCard(roomName);
    print('разыгырваемая карта в плэйспелл ${card?.name}');
    if(card?.name =='ЕДИНОРОЖИЙ ЯД') {
      if (myID == Provider
          .of<CurrentPlayerState>(context, listen:false)
          .currentPlayer) {
        print('мы на розыгрыше заклинания единорожий яд');
        await spellUnicornPoison(
          roomName,
          myID,
          otherID,
          card!,
          context,
        );
      }
    }
    else if(card?.name == 'ДВА ПО ЦЕНЕ ОДНОГО') {
      if (myID == Provider
          .of<CurrentPlayerState>(context, listen:false)
          .currentPlayer) {
        print('на условии что это заклинанеи два поцене одного');
        await twoForThePriceOfOne(
            context,
            roomName,
            myID,
            otherID);
      }
    }
    await Game.changeGameStatus('inProcess', roomName);
    await GameState.updateWithNewCardGameDeck(roomName, card!, 'discardPile');
    await GameState.removeCardGameDeck(roomName, card, 'playingCardOnTable',);
    await Game.checkCountCardOnHand(
      context,
      roomName,
      'hand',
      Provider
          .of<CurrentPlayerState>(context, listen: false)
          .currentPlayer,
      myID,
      otherID,
    );
    // await Game.cleanActCount(roomName);
    await Game.updatePlayOutCard(roomName, null);
    print('обнулили карту в спел если карта не два и не единорожий яд');
    // await Game.changeGameStatus('inProcess', roomName);
    // await Game.updateGameCardStatus(roomName, 'nothing');

    print('мы закончили розыгрыш заклинаний');


  }

}


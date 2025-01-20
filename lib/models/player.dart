import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/services/dialog/dialog_window.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_game.dart';
import '../const/const.dart';
import '../const/immortal_unicorns.dart';
import '../provider/current_player_provider.dart';
import '../provider/play_out_card_provider.dart';
import '../services/dialog/dialog_for_TPRU.dart';
import '../services/dialog/dialog_whithoutTPRU.dart';
import 'card.dart';
import 'game.dart';
import 'game_state.dart';

class Player {
  //разыгрываем карту
  static Future<void> playCard(BuildContext context,
      String roomName,
      String currentPlayer,
      String myID,
      String otherID,) async {
    CardModel? newCard = await Game.getPlayOutCard(roomName);
    print('разыгрываемая карта в плэйкард ${newCard?.name}');

    if (newCard?.type == CardClass.tpru) {
      DialogWindow.show(
          context, 'You can\'t play TPRU, choose another card', titleForDialogWindow);
    } else {
      await GameState.updateWithNewCardGameDeck(
        roomName,
        newCard!,
        'playingCardOnTable',
      );

      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        newCard,
        'hand',
        currentPlayer,
      );
      await Game.nextPlayer(
        roomName,
        currentPlayer,
        myID,
        otherID,
      );

      // String newCurrentPlayer = Provider
      //     .of<CurrentPlayerState>(context, listen: false)
      //     .currentPlayer;

      // String? userNickname = await Game.getNicknameById(
      //   otherID,
      //   roomName,
      // );
      await Game.changeGameStatus(
        'checkTPRU',
        roomName,
      );
    }
  }

  //проверка на наличие тпру у игрока
  static Future<void> checkTPRU(
      BuildContext context,
      String currentPlayer,
      String myID,
      String otherID,
      String roomName,) async {

// получаем значение разыгрываемой карты
    CardModel? newCard = await Game.getPlayOutCard(roomName);
    print('разыгрываемая карта в чектпру ${newCard?.name}');

    List<CardModel> handCards = await PlayerState.getPlayerDeck(
      roomName,
      'hand',
      currentPlayer,
    ) as List<CardModel>;

    List<CardModel> stallDeck = await PlayerState.getPlayerDeck(
      roomName,
      'stall',
      currentPlayer,
    ) as List<CardModel>;

    bool hasTpruCard = handCards.any((card) => card.type == CardClass.tpru);
    bool hasNoTpruUnicorn = stallDeck.any((card)=> card.name == 'ЖИРНОРОГ');

    if (hasTpruCard && !hasNoTpruUnicorn) {
      CardModel tpru = handCards.firstWhere((card) =>
      card.type == CardClass.tpru);

      await DialogForTPRU.show(
        context,
        tpru,
        currentPlayer,
        myID,
        otherID,
        newCard,
        roomName,
      );
    } else {
      await DialogWithoutTPRU.show(
        context,
        roomName,
        myID,
        otherID,
        newCard,
      );
    }
  }

//разыгрываем функцию карты
  static Future<void> activateCard(BuildContext context,
      CardModel newCard,
      String roomName,
      String myID,
      String otherID,) async {
    String currentPlayer = Provider
        .of<CurrentPlayerState>(context, listen: false)
        .currentPlayer;

    String otherId = currentPlayer == myID ? otherID : myID;
    // CardModel? jump;
    // List<CardModel>? bonuses = await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    // List<CardModel>? fines = await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    // List<CardModel>? effects = await PlayerState.getPlayerDeck(roomName, 'effects', myID);
    // bool isEven = fines?.any((card)=> card.name =='ОТСТОЙЛО') ?? false;
    //
    // bool isEvenJump = bonuses?.any((card)=> card.name =='ПРЫГ-СКОК') ?? false;
    // print('есть ли карта ПРЫГ-СКОК $isEvenJump ');
    // bool isEvenEffects = effects?.any((card)=> card.name =='ПРЫГ-СКОК') ?? false;
    // print('есть ли карта in effects $isEvenEffects ');
    //
    // if(isEvenJump && !isEven){
    //   jump = effects?.firstWhere((card)=> card.name =='ПРЫГ-СКОК');
    //   print('jump ${jump!.name} ');
    //
    // }

//единорог
    if (newCard.type == CardClass.unicorn) {
      print('тип карты единорог');
      await GameState.removeCardGameDeck(
        roomName,
        newCard,
        'playingCardOnTable',
      );
      await Game.changeGameStatus('playOutUnicorn', roomName);
    }
    else if (newCard.type == CardClass.spell) {
      print('тип карты заклинание');
      await Game.changeGameStatus('playOutSpell', roomName);
    }
    else if (newCard.type == CardClass.bonus) {
      print('тип карты бонус');

      await PlayerState.addCardPlayerDeck(
          roomName, newCard, 'bonuses', currentPlayer);
      await GameState.removeCardGameDeck(
        roomName,
        newCard,
        'playingCardOnTable',
      );
      // if( isEven || !isEvenJump || isEvenEffects) {
      //   print('нет прыг-скок или он не повторяется');
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
      // } else{
      //   print('есть прыг-скок или  2 хода');
      //   await Game.decreaseActCount(roomName);
      //   await PlayerState.addCardPlayerDeck(roomName, jump!, 'effects', myID);
      // }
      // await PlayerState.updatePlayerDeck(roomName, [], 'effects', myID);
      await Game.updatePlayOutCard(roomName, null);
      print('обнулили карту в бонусах или штрафах');

    }
    else if (newCard.type == CardClass.fine) {
    print('тип карты штраф');

    await PlayerState.addCardPlayerDeck(
    roomName, newCard, 'fines', otherId);

    await GameState.removeCardGameDeck(
      roomName,
      newCard,
      'playingCardOnTable',
    );
    // if( isEven || !isEvenJump || isEvenEffects) {
    //   print('нет прыг-скок или он не повторяется');
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
    // } else{
    //   print('есть прыг-скок или  2 хода');
    //   await Game.decreaseActCount(roomName);
    //   await PlayerState.addCardPlayerDeck(roomName, jump!, 'effects', myID);
    // }
    await PlayerState.updatePlayerDeck(roomName, [], 'effects', myID);
    await Game.updatePlayOutCard(roomName, null);
    print('обнулили карту в штрафах');

    }


    }

  static Future<bool> checkCardOnTableForDraw(String roomName) async {
    try {
      List<CardModel> cardOnTable =
      await GameState.getDeck(roomName, 'playingCardOnTable');

      int countCard = cardOnTable.length;
      return countCard % 2 == 0 ? true : false;
    } catch (e) {
      print('Error fetching cards from table: $e');
      return false;
    }
  }


// сбросить карту в сброс
  static Future<void> cardDiscard(BuildContext context,
      String roomName,
      CardModel newCard,
      String myID,) async {
    await GameState.updateWithNewCardGameDeck(
        roomName, newCard, 'discardPile');
    await PlayerState.removeCardFromPlayerDeck(
        roomName, newCard, 'hand', myID);
  }

//уничтожить единорога соперника
  static Future<void> destroyUnicorn(
      CardModel? destroyCard,
      String roomName,
      String otherID,
      ) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName, destroyCard!, 'stall', otherID);
    if (immortalUnicorns.contains(destroyCard.name)) {
      print('Имя карты "${destroyCard
          .name}" совпадает с одним из известных имен единорогов.');
      await PlayerState.addCardPlayerDeck(
          roomName, destroyCard, 'hand', otherID);
    } else if (
    destroyCard.type!= CardClass.baby) {
      print('убиваемый единорожек это не малыш');
      await GameState.updateWithNewCardGameDeck(
          roomName,
          destroyCard,
          'discardPile');
    }
  }

  //уничтожить бонус
  static Future<void> destroyBonus(CardModel? destroyCard,
      String roomName,
      String otherID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'bonuses',
        otherID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  // уничтожить штраф
  static Future<void> destroyFine(CardModel? destroyCard,
      String roomName,
      String otherID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'fines',
        otherID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  //уничтож или или
  static Future<void> destroyBonusOrFine(CardModel? destroyCard,
      String roomName,
      String otherID,
      String myID,) async {
    if (destroyCard?.type == CardClass.fine) {
      await Player.sacrificeFines(destroyCard, roomName, myID);
    }

    if (destroyCard?.type == CardClass.bonus) {
      await Player.destroyBonus(destroyCard, roomName, otherID);
    }
  }

//принести в жертву единорога
  static Future<void> sacrificeUnicorn(roomName,
      destroyCard,
      myID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName, destroyCard!, 'stall', myID);
    if (immortalUnicorns.contains(destroyCard.name)) {
      print('Имя карты "${destroyCard
          .name}" совпадает с одним из известных имен единорогов.');
      await PlayerState.addCardPlayerDeck(
          roomName, destroyCard, 'hand', myID);
    } else if (
    destroyCard.name != 'Baby') {
      await GameState.updateWithNewCardGameDeck(
          roomName, destroyCard!, 'discardPile');
    } else {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, destroyCard!, 'stall', myID);
    }
  }

  //принести в жертву бонус
  static Future<void> sacrificeBonus(CardModel? destroyCard,
      String roomName,
      String myID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'bonuses',
        myID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  //принести в жертву  штраф
  static Future<void> sacrificeFines(CardModel? destroyCard,
      String roomName,
      String myID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'fines',
        myID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }


  //переместить карту откуда-то куда-то на стол
  static Future<void> changeCardFromPlayerDeck(CardModel card,
      String roomName,
      String fromID,
      String toID,) async {
    if (card.type == CardClass.fine) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'fines', fromID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'fines', toID);
    } else if (card.type == CardClass.bonus) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'bonuses', fromID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'bonuses', toID);
    } else if (card.type == CardClass.unicorn) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'stall', fromID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'stall', toID);
    }
  }


// перенести карту из рук в руки, со стола в руки
  static Future<void> moveCardFromPDToPD(CardModel card,
      String roomName,
      String fromDeck,
      String toDeck,
      String fromID,
      String toID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName, card, fromDeck, fromID);
    await PlayerState.addCardPlayerDeck(roomName, card, toDeck, toID);
  }

  // взять карту из колоды игры на руки
  static Future<void> moveCardFromGDToPD(CardModel card,
      String roomName,
      String fromDeck,
      String toDeck,
      String toID,) async {
    await GameState.removeCardGameDeck(roomName, card, fromDeck);
    await PlayerState.addCardPlayerDeck(roomName, card, toDeck, toID);
  }

  //all stall
  static Future<List<CardModel>?> takeAllCardOnStall(String roomName,
      String playerID,) async {
    List<CardModel> allCard = [];
    List<CardModel>? bonuses = [];
    List<CardModel>? stall = [];
    List<CardModel>? fines = [];

    bonuses = await PlayerState.getPlayerDeck(roomName, 'bonuses', playerID);
    if (bonuses!.isNotEmpty) {
      allCard.addAll(bonuses);
    }

    stall = await PlayerState.getPlayerDeck(roomName, 'stall', playerID);
    if (stall!.isNotEmpty) {
      allCard.addAll(stall);
    }

    fines = await PlayerState.getPlayerDeck(roomName, 'fines', playerID);
    if (fines!.isNotEmpty) {
      allCard.addAll(fines);
    }
    return allCard;
  }


  //взять карту любую со стола на руки
  static Future<List<CardModel>?> takeCardOnHand(
      CardModel card,
      String roomName,
      String playerID,) async {
    if (card.type == CardClass.fine) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'fines', playerID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'hand', playerID);
    } else if (card.type == CardClass.bonus) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'bonuses', playerID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'hand', playerID);
    } else if (card.type == CardClass.unicorn) {
        await PlayerState.removeCardFromPlayerDeck(
            roomName, card, 'stall', playerID);
        await PlayerState.addCardPlayerDeck(roomName, card, 'hand', playerID);
      } else if (card.type == CardClass.baby){
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'stall', playerID);
    }
  }

  //получить колоду определенных карт из колоды игры
  static Future<List<CardModel>?> takeSpecificCardsFromGDTOPD(
      CardClass cardType,
      String roomName,
      String fromGD,) async {
    List<CardModel>? cards = [];

    List<CardModel> cardsGameDeck = await GameState.getDeck(roomName, fromGD);
    cards = cardsGameDeck.where((card) => card.type == cardType).toList();

    return cards;


  }

  static Future<void> moveCardWithIndex(
      String roomName,
      String otherID,
      String myID,
  ) async {

    List<CardModel>? deck = await PlayerState.getPlayerDeck(roomName, 'hand', otherID);
    Random random = Random();
   deck!.shuffle();
    int randomIndex = random.nextInt(deck.length-1);
    await moveCardFromPDToPD(deck[randomIndex], roomName, 'hand', 'hand', otherID, myID);
  }

  static Future<void> shuffleDeckWithNewCard(
      String roomName,
      CardModel? card,
      String typeDeck,
  ) async {

    List<CardModel>? deck = await GameState.getDeck(roomName, typeDeck);
    deck.add(card!);

    deck.shuffle();

    await GameState.updateDeck(roomName, deck, 'deck');
  }

}

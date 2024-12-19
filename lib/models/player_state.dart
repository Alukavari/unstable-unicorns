import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/deck.dart';
import 'package:unstable_unicorns/services/dialog_for_TPRU.dart';
import 'package:unstable_unicorns/services/dialog_whithoutTPRU.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';
import '../provider/current_player_provider.dart';
import '../provider/draw_card_provider.dart';
import '../provider/game_data_provider.dart';
import 'card.dart';
import 'card.dart';
import 'card.dart';
import 'game.dart';
import 'game_state.dart';

class PlayerState {
  //инициализация состояния игрока
  static Future<void> setPlayerState(String roomName, String playerId) async {
    final playerStateRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerId);

    await playerStateRef.set({
      'hand': [],
      'stall': [],
      'effects': [],
      'fines': [],
      'bonuses': [],
      'isOnline': true,
    });
  }

  //update player deck
  static Future<void> updatePlayerDeck(String roomName, List<CardModel> cards,
      String typeDeck, String playerID) async {
    List<Map<String, dynamic>> cardData =
        cards.map((card) => card.toMap()).toList();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .update({
      typeDeck: cardData,
    });
  }

  //раздача карт
  static Future<void> drawnCards(
      String roomName,
      BuildContext context,
      List<CardModel> babyDeck,
      List<CardModel> cards,
      int count,
      String playerID1,
      String playerID2) async {
    final deck = cards;

    List<CardModel> deckForBD = [];

    List<CardModel> babyCards = List.from(babyDeck);
    List<CardModel> player1CardsOnHand = [];
    List<CardModel> player2CardsOnHand = [];

    List<CardModel> player1CardsOnTable = [];
    List<CardModel> player2CardsOnTable = [];

    Random random = Random();

    int babyIndex1 = random.nextInt(babyCards.length);
    player1CardsOnTable.add(babyCards[babyIndex1]);
    babyCards.removeAt(babyIndex1);

    print('малыш который добавился 1 игроку${player1CardsOnTable[0].id}');

    int babyIndex2 = random.nextInt(babyCards.length);
    player2CardsOnTable.add(babyCards[babyIndex2]);
    babyCards.removeAt(babyIndex2);
    print('малыш который добавился 2 игроку${player2CardsOnTable[0].id}');

    deck.shuffle();
    print('сколько карт всего ${deck.length}');
    if (deck.length >= count * 2) {
      for (int i = 0; i < count; i++) {
        int randomIndex1 = random.nextInt(deck.length);
        if (!player1CardsOnHand
            .any((card) => card.id == deck[randomIndex1].id)) {
          player1CardsOnHand.add(deck[randomIndex1]);
          deck.removeAt(randomIndex1);
        } else {
          i--;
        }
      }
      print(
          'сколько осталось карт в колоде после первой раздачи ${deck.length}');
      CardModel cardFor1Player =
          deck.firstWhere((card) => card.type == CardClass.tpru);
      print('Добавляем карту тпру игрока 1: ${cardFor1Player.id}');
      player1CardsOnHand.add(cardFor1Player);
      print(
          'сколько карт у 1 игрока после добавления тпру ${player1CardsOnHand.length}');

      deck.remove(cardFor1Player);
      for (var card in deck) {
        print('ID карты: после удаления ${card.id}');
      }

      try {
        await updatePlayerDeck(
            roomName, player1CardsOnTable, 'stall', playerID1);
        await updatePlayerDeck(roomName, player1CardsOnHand, 'hand', playerID1);
      } catch (e) {
        print('Error in updating decks: $e');
      }

      for (int i = 0; i < count; i++) {
        int randomIndex2 = random.nextInt(deck.length);
        if (!player1CardsOnHand
                .any((card) => card.id == deck[randomIndex2].id) &&
            !player2CardsOnHand
                .any((card) => card.id == deck[randomIndex2].id)) {
          player2CardsOnHand.add(deck[randomIndex2]);
          deck.removeAt(randomIndex2);
        } else {
          i--; // Если карта уже есть, повторяем итерацию
        }
      }
      print(
          'сколько осталось карт в колоде после второй раздачи ${deck.length}');
      CardModel cardFor2Player =
          deck.firstWhere((card) => card.type == CardClass.tpru);
      print('какую карту я добавляю 2 игроку ${cardFor2Player.id}');

      print('Добавляем карту игрока 1: ${cardFor2Player.id}');
      player2CardsOnHand.add(cardFor2Player);
      print(
          'сколько карт у 2 игрока после добавления тпру ${player2CardsOnHand.length}');
      deck.remove(cardFor2Player);
      print(
          'сколько осталось карт в колоде после второй раздачи 6 + тпру ${deck.length}');

      try {
        await updatePlayerDeck(
            roomName, player2CardsOnTable, 'stall', playerID2);
        await updatePlayerDeck(roomName, player2CardsOnHand, 'hand', playerID2);
      } catch (e) {
        print('Error in updating decks: $e');
      }
      for (int i = 0; i < deck.length; i++) {
        if (!player1CardsOnHand.any((card) => card.id == deck[i].id) &&
            !player2CardsOnHand.any((card) => card.id == deck[i].id)) {
          deckForBD.add(deck[i]);
          print('какую карту добавляем ${deck[i].id}');
        }
      }

      print('сколько уникальных карт в колоде ${deckForBD.length}');
      // обновить колодe в firestore
      for (int i = 0; i < deckForBD.length; i++) {
        print('карты в дек для бд: ${deckForBD[i].id}');
      }
      try {
        await GameState.updateDeck(roomName, deckForBD);
      } catch (e) {
        print('Error in updating decks: $e');
      }
    } else {
      print('Not enough cards in deck to draw: ${deckForBD.length} available');
    }
  }

  static Future<List<CardModel>?> getPlayerDeck(
      String roomName, String typeDeck, String playerID) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey(typeDeck)) {
        List<dynamic> cardsData = data[typeDeck];

        List<CardModel> cards =
            cardsData.map((cardData) => CardModel.fromMap(cardData)).toList();
        return cards;
      }
    }
    return null; // Если колода не найдена
  }

  //add new cards PlayerDeck
  static Future<void> addCardsPlayerDeck(
      String roomName,
      CardModel newCards,
      String typeDeck,
      // String typeGameDeck,
      String playerID) async {
    Map<String, dynamic> newCardMaps = newCards.toMap();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .update({
      typeDeck: FieldValue.arrayUnion([newCardMaps]),
    });

  }

  //remove from playerDeck
  static Future<void> removeCardFromPlayerDeck(String roomName,
      CardModel newCard, String typeDeck, String playerID) async {
    // List<Map<String, dynamic>> newCardMaps = newCards.map((card) => card.toMap()).toList();
    Map<String, dynamic> newCardMaps = newCard.toMap();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .update({
      typeDeck: FieldValue.arrayRemove([newCardMaps]),
    });
  }

//проверяем на наличие ТПРУ
  static Future<void> checkTPRU(
    BuildContext context,
    String currentPlayer,
    String myID,
    String otherID,
    String roomName,
  ) async {
    print('мы перешли на чекТПРУ');

// получаем значение разыгрываемой карты
    CardModel? newCard = await Game.getDrawCard(roomName);
    print('разыгрываемая карта ${newCard?.name}');

    List<CardModel> handCards = await PlayerState.getPlayerDeck(
      roomName,
      'hand',
      currentPlayer,
    ) as List<CardModel>;

    bool hasTpruCard = handCards.any((card) => card.type == CardClass.tpru);
    print('проверяем наличие тпру у $currentPlayer и это $hasTpruCard');

    if (hasTpruCard) {
      print('есть тпру');
      CardModel tpru =
          handCards.firstWhere((card) => card.type == CardClass.tpru);

      print('мы на диалоге для тпру');
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
      //если отказывается выкладывать тпру
      print('$currentPlayer отказался выкладывать тпру');
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
  static Future<void> activateCard(
    BuildContext context,
    CardModel newCard,
    String roomName,
    String myID,
    String otherID,
  ) async {
    String currentPlayer =
        Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;

    String otherId = currentPlayer == myID ? otherID : myID;

    final deckCard = await GameState.getDeck(roomName, 'playingCardOnTable');
    if (deckCard.isNotEmpty) {
      CardModel? typeCard = CardModel.splitDeckWithType(deckCard);

      if (typeCard.type == CardClass.unicorn) {
        await PlayerState.addCardsPlayerDeck(
            roomName, typeCard, 'stall', currentPlayer);
        await GameState.removeCardGameDeck(
          roomName,
          typeCard,
          'playingCardOnTable',
        );
      } else if (typeCard.type == CardClass.bonus) {
        await PlayerState.addCardsPlayerDeck(
            roomName, typeCard, 'bonuses', currentPlayer);
        await GameState.removeCardGameDeck(
          roomName,
          typeCard,
          'playingCardOnTable',
        );
      } else if (typeCard.type == CardClass.fine) {
        await PlayerState.addCardsPlayerDeck(
            roomName, typeCard, 'fines', otherId);

        await GameState.removeCardGameDeck(
          roomName,
          typeCard,
          'playingCardOnTable',
        );
      }
    }

    print('конец розыгрыша карты на стол');

    await Game.updateDrawCard(
      roomName,
      null,
    );

    Provider.of<DrawCardProvider>(context, listen: false).updateDrawCard(null);
    print(
        'разыгырваемая карта теперь должна быть нолль ${Provider.of<DrawCardProvider>(context, listen: false).drawCard}');
  }

  //забрать карту из сброса на руки
  static Future<void> takeCardPile(
    BuildContext context,
    String roomName,
    String currentPlayer,
    String typeGameDeck,
    String typePlayerDeck,
    int countTake,
    String myID,
    String otherID,
    CardModel newCards,
  ) async {
//добавляем карту в руки игроку
    await PlayerState.addCardsPlayerDeck(
      roomName,
      newCards,
      'hand',
      // 'discardPile',
      currentPlayer,
    );
//удаляем карту из колоды сброса
    await GameState.removeCardGameDeck(
      roomName,
      newCards,
      'discardPile',
    );
    await Game.nextPlayer(roomName, currentPlayer, myID, otherID);
  }

  //проверяем можно ли разыгрывать карту после битвы тпру

  static Future<bool> checkCardOnTableForDraw(String roomName) async {
    try {
      List<CardModel> cardOnTable =
          await GameState.getDeck(roomName, 'playingCardOnTable');
      print('проверяем четность карт есть ли колода ${cardOnTable.length}');

      int countCard = cardOnTable.length;
      return countCard % 2 == 0 ? true : false;
    } catch (e) {
      print('Error fetching cards from table: $e');
      return false;
    }
  }
}

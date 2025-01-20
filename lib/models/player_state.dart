import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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


    int babyIndex2 = random.nextInt(babyCards.length);
    player2CardsOnTable.add(babyCards[babyIndex2]);
    babyCards.removeAt(babyIndex2);

    deck.shuffle();
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
      CardModel cardFor1Player = deck.firstWhere((card) => card.type == CardClass.tpru);
      player1CardsOnHand.add(cardFor1Player);

      deck.remove(cardFor1Player);
      for (var card in deck) {
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

      CardModel cardFor2Player = deck.firstWhere((card) => card.type == CardClass.tpru);

      player2CardsOnHand.add(cardFor2Player);
      deck.remove(cardFor2Player);

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
        }
      }

      // обновить колодe в firestore
      for (int i = 0; i < deckForBD.length; i++) {
      }
      try {
        await GameState.updateDeck(roomName, deckForBD, 'deck');
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
  static Future<void> addCardPlayerDeck(
      String roomName,
      CardModel newCard,
      String typeDeck,
      String playerID) async {
    Map<String, dynamic> newCardMap = newCard.toMap();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .update({
      typeDeck: FieldValue.arrayUnion([newCardMap]),
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



}

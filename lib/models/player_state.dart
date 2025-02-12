import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'card.dart';
import 'deck.dart';
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
      // List<CardModel> babyDeck,
      // List<CardModel> cards,
      int count,
      String playerID1,
      String playerID2
      ) async {

    print('playerID1 $playerID1');
    print('playerID2 $playerID2');

    List<CardModel> allDeck = [];
    allDeck.addAll(cards);

    // List<CardModel> uniDeck = [];

    // uniDeck.addAll(babyDeck);

    // final deck = cards;


    List<CardModel> deck2 = [];

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

    allDeck.shuffle();
    if (allDeck.length >= count * 2) {
      // if (deck.length >= count) {
      // for (int i = 0; i < count; i++) {
      for (int i = 0; i < count; i++) {
        int randomIndex1 = random.nextInt(allDeck.length);
        if (!player1CardsOnHand
            .any((card) => card.id == allDeck[randomIndex1].id)) {
          player1CardsOnHand.add(allDeck[randomIndex1]);
          allDeck.removeAt(randomIndex1);
        } else {
          i--;
        }
      }
      CardModel cardFor1Player = allDeck.firstWhere((card) =>
      card.type == CardClass.tpru);
      player1CardsOnHand.add(cardFor1Player);

      allDeck.remove(cardFor1Player);

      for (int i = 0; i < player1CardsOnHand.length; i++) {
        print('card on hand1player ${player1CardsOnHand[i].name}');
      }

      for (int i = 0; i < allDeck.length; i++) {
        print('card on deck ${allDeck[i].name}');
      }

      try {
        await updatePlayerDeck(
            roomName, player1CardsOnTable, 'stall', playerID1);
        await updatePlayerDeck(roomName, player1CardsOnHand, 'hand', playerID1);
        // add
        await GameState.updateDeck(roomName, allDeck, 'deck');
      } catch (e) {
        print('Error in updating decks: $e');
      }

      deck2 = await GameState.getDeck(roomName, 'deck');

      for (int i = 0; i < count; i++) {
        int randomIndex2 = random.nextInt(deck2.length);
        if (!player1CardsOnHand
                .any((card) => card.id == deck2[randomIndex2].id) &&
            !player2CardsOnHand
                .any((card) => card.id == deck2[randomIndex2].id)) {
          player2CardsOnHand.add(deck2[randomIndex2]);
          deck2.removeAt(randomIndex2);
        } else {
          i--; // Если карта уже есть, повторяем итерацию
        }
      }

        CardModel cardFor2Player = deck2.firstWhere((card) => card.type == CardClass.tpru);

        player2CardsOnHand.add(cardFor2Player);
      deck2.remove(cardFor2Player);

        for(int i = 0; i<player2CardsOnHand.length; i++){
          print('card on hand2player ${player2CardsOnHand[i].name}');
        }

        try {
          await updatePlayerDeck(
              roomName, player2CardsOnTable, 'stall', playerID2);
          await updatePlayerDeck(roomName, player2CardsOnHand, 'hand', playerID2);
        } catch (e) {
          print('Error in updating decks: $e');
        }



        // обновить колодe в firestore
        for (int i = 0; i < deck2.length; i++) {
          print('card on deck ${deck2[i].name}');

        }
        try {
          await GameState.updateDeck(roomName, deck2, 'deck');
        } catch (e) {
          print('Error in updating decks: $e');
        }
      } else {
        print('Not enough cards in deck to draw: ${deck2.length} available');
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

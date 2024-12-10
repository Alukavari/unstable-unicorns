import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/services/dialog_for_TPRU.dart';
import 'package:unstable_unicorns/services/dialog_whithoutTPRU.dart';
import '../services/game_data_provider.dart';
import 'card.dart';
import 'game.dart';
import 'game_state.dart';

class PlayerState {
  String playerId; // ID игрока
  List<CardModel> hand; // Карты в руке
  List<CardModel> stall; // карты в стойле
  List<CardModel> fines; // штрафы на столе
  List<CardModel> bonuses; // бонусы на столе
  Map<String, dynamic> effects; // Текущие эффекты или ограничения на игрока

  PlayerState({
    required this.playerId,
    required this.hand,
    required this.effects,
    required this.stall,
    required this.fines,
    required this.bonuses,
  });

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

    List<CardModel> babyCards = List.from(babyDeck);
    List<CardModel> player1CardsOnHand = [];
    List<CardModel> player2CardsOnHand = [];

    List<CardModel> player1CardsOnTable = [];
    List<CardModel> player2CardsOnTable = [];

    //добавляем 1 тпру на руки
    player1CardsOnHand.add(CardModel(
        'ТПРУ',
        'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
        CardClass.tpru,
        'assets/13tpru.png',
        '13tpru'));
    player2CardsOnHand.add(CardModel(
        'ТПРУ',
        'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
        CardClass.tpru,
        'assets/14tpru.png',
        '14tpru'));

    // добавяем малыша на стол
    Random random = Random();

    int babyIndex1 = random.nextInt(babyCards.length);
    player1CardsOnTable.add(babyCards[babyIndex1]);
    babyCards.removeAt(babyIndex1);

    int babyIndex2 = random.nextInt(babyCards.length);
    player2CardsOnTable.add(babyCards[babyIndex2]);
    babyCards.removeAt(babyIndex2);

    // Вытаскиваем по 6 случайных карт из основной колоды для каждого игрока
    deck.shuffle();
    if (deck.length >= count) {
      for (int i = 0; i < count; i++) {
        int randomIndex1 = random.nextInt(deck.length);
        player1CardsOnHand.add(deck[randomIndex1]);
        deck.removeAt(randomIndex1);

        int randomIndex2 = random.nextInt(deck.length);
        player2CardsOnHand.add(deck[randomIndex2]);
        deck.removeAt(randomIndex2);
      }
      // обновить колоды в firestore
      try {
        await GameState.updateDeck(roomName, deck);
        await updatePlayerDeck(
            roomName, player1CardsOnTable, 'stall', playerID1);
        await updatePlayerDeck(
            roomName, player2CardsOnTable, 'stall', playerID2);

        await updatePlayerDeck(roomName, player1CardsOnHand, 'hand', playerID1);
        await updatePlayerDeck(roomName, player2CardsOnHand, 'hand', playerID2);
      } catch (e) {
        print('Error in updating decks: $e');
      }
    } else {
      print('Not enough cards in deck to draw: ${deck.length} available');
    }
  }

  //get player deck fines/effects/bonuses..
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
  static Future<void> addCardsPlayerDeck(String roomName, CardModel newCards,
      String typeDeck, String typeGameDeck, String playerID) async {
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

    await GameState.removeCardGameDeck(roomName, newCards, typeGameDeck);
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
    List<CardModel> handCards,
    CardModel newCard,
    String myID,
    String otherID,
    String roomName,
      // Function(int) checkCount,
      ) async {
print('мы перешли на чекТПРУ');

    bool hasTpRuCard = handCards.any((card) => card.type == 'tpru');

    if (hasTpRuCard) {
      CardModel tpru = handCards.firstWhere((card) => card.type == 'tpru');

      await GameState.updateWithNewCardGameDeck(roomName, tpru, 'playingCardOnTable');
      await Game.nextPlayer(roomName, currentPlayer, myID, otherID);

      await DialogForTPRU.show(
        context,
        //разыграть тпру
        () async => await GameState.updateWithNewCardGameDeck(
          roomName,
          tpru,
          'playingCardOnTable',
        ),
        //onPressedNextPlayer
          () async => await Game.nextPlayer(roomName, currentPlayer, myID, otherID),

        // разыгрывет карту
        () async => await activateCard(
            newCard,
            roomName,
            currentPlayer,
            // checkCount,
        ),
        // onPressedCheckTPRU
        () async => await checkTPRU(
          context,
          currentPlayer,
          handCards,
          newCard,
          myID,
          otherID,
          roomName,
          // checkCount,
        ),
      );
    } else {
      //если отказывается выкладывать тпру
     await DialogWithoutTPRU.show(
        context,
        // onPressedNextPlayer,
         () async => await Game.nextPlayer(roomName, currentPlayer, myID, otherID),
       () async => await activateCard(
            newCard,
            roomName,
            currentPlayer,
         // checkCount,
        ),
      );
    }
  }


  static Future<void> activateCard(
      CardModel newCard,
      String roomName,
      String currentPlayer, // Function(int) checkCount,

      )async{
    GameDataProvider gameData = GameDataProvider();

    print('начинаем разыгрывать карту');

    await PlayerState.addCardsPlayerDeck(
        roomName,
        newCard,
        'hand',
        'deck',
        currentPlayer
    );

    print('разфграли карту');

//добавили карты со стола в сброс
    final deckCard = await GameState.getDeck(
        roomName,
        'playingCardOnTable'
    );
    if(deckCard.isNotEmpty){
      await GameState.addNewGameDeck(
          roomName,
          deckCard,
          'discardPile');
      print('добавили все в сброс');
    }

    gameData.cleanCount();
    print('обнуяем коунт');

  }
}

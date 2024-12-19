import 'package:cloud_firestore/cloud_firestore.dart';
import 'card.dart';

class GameState {

  static Future<void> updateWithNewCardGameDeck(
      String roomName,
      CardModel newCard,
      String typeDeck) async {
    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      typeDeck: FieldValue.arrayUnion([newCard.toMap()]),
    });
  }

//добавить целую колоду
  static Future<void> addNewGameDeck(
      String roomName,
      List<CardModel> newCards,
      String typeDeck) async {

    List<Map<String, dynamic>> newCardMaps = newCards.map((card) => card.toMap()).toList();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      // typeDeck: FieldValue.arrayUnion([newCardMaps]),
      typeDeck: FieldValue.arrayUnion(newCardMaps),
    });
  }

  //remove card from game deck
  static Future<void> removeCardGameDeck(
      String roomName,
      CardModel newCards,
      String typeDeck) async {
    // List<Map<String, dynamic>> newCardMaps = newCards.map((card) => card.toMap()).toList();
    Map<String, dynamic> newCardMaps = newCards.toMap();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      typeDeck: FieldValue.arrayRemove([newCardMaps]),
    });
  }

  static Future<void> removeNewGameDeck(
      String roomName,
      String typeDeck) async {

    // List<Map<String, dynamic>> newCardMaps = newCards.map((card) => card.toMap()).toList();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      typeDeck: [],
        });
  }

  // Метод для преобразования колоды в список Map для Firestore
  static List<Map<String, dynamic>> deckToMap(List<CardModel> deck) {
    return deck.map((card) => card.toMap()).toList();
  }

// update deck
  static Future<void> updateDeck(String roomName, List<CardModel> cards) async {
    List<Map<String, dynamic>> cardData =
    cards.map((card) => card.toMap()).toList();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      'deck': cardData,
    });
  }

  // get deck
  static Future<List<CardModel>> getDeck(String roomName, String typeDeck) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey(typeDeck)) {
        List<dynamic> cardsData = data[typeDeck];

        List<CardModel> cards =
        cardsData.map((cardData) => CardModel.fromMap(cardData)).toList();
        return cards;
      }
    }List<CardModel> cards = [];
    return cards; // Если колода не найдена
  }

}

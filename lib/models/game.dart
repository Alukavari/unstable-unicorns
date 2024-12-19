import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/screens/lobby.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';

import '../services/dialog_for_finish.dart';
import '../services/dialog_window.dart';
import '../provider/game_data_provider.dart';
import '../services/snack_bar.dart';
import 'card.dart';

class Game {
  // start game
  static Future<void> startGame(
      String roomName, String playerID1, String playerID2) async {
    await FirebaseFirestore.instance.collection(roomName).doc('room').set({
      'players': [playerID1, playerID2],
      'gameStatus': 'waiting', // ожидание начала игры
      'currentTurn': playerID1,
      'gameWin': '',
      'drawCard': [],
      'lastActive': FieldValue.serverTimestamp(),

    });

    final roomRef2 =
        FirebaseFirestore.instance.collection(roomName).doc('room');
    final roomData = await roomRef2.get();

    if ((!roomData.exists || roomData.data()?['players'] == null)) return;
    final players = List<String>.from(roomData.data()?['players']);

    await roomRef2.collection('GameState').doc('state').set({
      'deck': [],
      'discardPile': [],
      'playingCardOnTable': [],
    });

    for (String playerID in players) {
      await PlayerState.setPlayerState(roomName, playerID);
    }

    await roomRef2.update({
      'gameStatus': 'inProcess',
      'currentTurn': players.first,
    });

    // await roomRef2.collection('message').doc('action').set({
    //   'actionType': '',
    //   'playerId': '',
    //   'lastActive': FieldValue.serverTimestamp(),
    // });

    await roomRef2.collection('action').doc('state').set({
      'actCount': 0,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  //get current player
  static Future<String> currentPlayer(String roomName) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc('room');

    final roomData = await roomRef.get();
    if (!roomData.exists || roomData.data()?['currentTurn'] == null) {
      return 'not found';
    }
    String currentTurn = roomData.data()?['currentTurn'];
    return currentTurn;
  }

// update current player
  static Future<void> nextPlayer(
    String roomName,
    String currentPlayer,
    String myID,
    String otherID,
  ) async {
    final roomRef = FirebaseFirestore.instance.collection(roomName).doc('room');

    String nextPlayer = (currentPlayer == myID) ? otherID : myID;

    await roomRef.update({
      'currentTurn': nextPlayer,
    });
  }

  static Future<void> spentMessage(
      String currentPlayer, String roomName, String actionType) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('message')
        .doc('action')
        .update({
      'actionType': actionType,
      'playerId': currentPlayer,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> changeGameStatus(
    String gameStatus,
    String roomName,
  ) async {
    final roomRef =
        FirebaseFirestore.instance.collection(roomName).doc('room').update({
      'gameStatus': gameStatus,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> cleanActCount(
    String roomName,
  ) async {
    final roomRef =
        FirebaseFirestore.instance.collection(roomName)
            .doc('room')
        .collection('action')
        .doc('state')
            .update({
      'actCount': 0,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<int?> getActCount(
    String roomName,
  ) async {
    final roomRef =
        await FirebaseFirestore.instance.collection(roomName).doc('room').collection('action')
            .doc('state').get();
    if (roomRef.exists) {
      Map<String, dynamic>? data = roomRef.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('actCount')) {
        int actCount = data['actCount'] ?? '';
        return actCount;
      }
    }
  }

  static Future<void> incrementActCount(
    String roomName,
  ) async {
    int? actCount = await getActCount(roomName) ?? 0;
    final roomRef =
        FirebaseFirestore.instance.collection(roomName).doc('room').collection('action')
            .doc('state').update({
      'actCount': actCount + 1,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> changeWinner(
    String currentPlayer,
    String roomName,
  ) async {
    final roomRef =
        FirebaseFirestore.instance.collection(roomName).doc('room').update({
      'gameWin': currentPlayer,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> getGameStatus(String roomName) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection(roomName).doc('room').get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('gameStatus')) {
        String gameStatus = data['gameStatus'] ?? '';
        return gameStatus;
      }
    }
  }

  static Future<void> updateDrawCard(String roomName, CardModel? cards) async {
    Map<String, dynamic>? newCardMaps = cards?.toMap();

    await FirebaseFirestore.instance.collection(roomName).doc('room').update({
      'drawCard': newCardMaps,
    });
  }

  static Future<CardModel?> getDrawCard(String roomName) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection(roomName).doc('room').get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('drawCard')) {
        Map<String, dynamic> cardData = data['drawCard'];

        // List<CardModel> cards =
        // cardsData.map((cardData) => CardModel.fromMap(cardData)).toList();
        // cardData.map((cardData) => CardModel.fromMap(cardData)).toList();
        return CardModel.fromMap(cardData);
      }
    }
    // List<CardModel> cards = [];
    print('не нашли разыгрываемую карту');
    return null; // Если колода не найдена
  }

  static Future<String?> getNicknameById(String userId, String roomName) async {
    try {
      final roomRef = FirebaseFirestore.instance.collection(roomName);
      String userNickname = '';
      final roomData = await roomRef.doc('player1').get();
      final roomData2 = await roomRef.doc('player2').get();

      if (!roomData.exists || !roomData2.exists) {
        return null;
      } else {
        if (roomData.data()?['playerID'] == userId) {
          userNickname = roomData.data()?['user_nickname'];
          return userNickname;
        }

        if (roomData2.data()?['playerID'] == userId) {
          userNickname = roomData2.data()?['user_nickname'];
          return userNickname;
        }
      }
    } catch (e) {
      print('Ошибка при получении никнейма: $e');
      return null;
    }
    print('Документ не существует');
    return null;
  }

  static Future<String?> getUserNicknameByEmail(String playerID) async {
    var userNickname = '';
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await users.where('playerID', isEqualTo: playerID).get();
    if (querySnapshot.docs.isNotEmpty) {
      userNickname = querySnapshot.docs.first['userNickname'];
    } else {
      SnackBarService.showSnackBar(
          userNickname as BuildContext, 'Nickname not found...', false);
    }
    return userNickname;
  }

  static Future<String> getEmailByID(String playerID) async {
    var userEmail = '';
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await users.where('playerID', isEqualTo: playerID).get();
    if (querySnapshot.docs.isNotEmpty) {
      userEmail = querySnapshot.docs.first['email'];
    } else {
      SnackBarService.showSnackBar(
          userEmail as BuildContext, 'Email not found...', false);
    }
    return userEmail;
  }

  static Future<void> checkCountCardOnHand(
    BuildContext context,
    String roomName,
    String typeDeck,
    String currentPlayer,
    String myID,
    String otherID,
  ) async {
    print('мы на чеккоунт семи');
    // String? gameStatus = await Game.getGameStatus(roomName);

    List<CardModel>? cardsOnHand = await PlayerState.getPlayerDeck(
      roomName,
      typeDeck,
      currentPlayer,
    );
    int countCardsOnHand = cardsOnHand?.length ?? 0;
    int difference = 0;
    print('сколько карт на руках $countCardsOnHand');

    if (countCardsOnHand >= 0 && countCardsOnHand <= 7) {
      // Provider.of<GameDataProvider>(context, listen: false).cleanCount();
      print(
          'до обнуления в чек кард он хэнд ${Provider.of<GameDataProvider>(context, listen: false).actCount}');
      // if (gameStatus == 'inProcess') {
      print('до семи');

      // Provider.of<GameDataProvider>(context, listen: false).cleanCount();

      await Game.checkVictoryConditions(
        roomName,
        currentPlayer,
      );

      await Game.nextPlayer(
        roomName,
        currentPlayer,
        myID,
        otherID,
      );

      await Game.cleanActCount(roomName);
      // Provider.of<GameDataProvider>(context, listen: false).updateActCount(0);
      print(
          'обнулили коунт после смены игрока текущего ${Provider.of<GameDataProvider>(context, listen: false).actCount}');
      // }
    } else {
      print('больше семи');
      await Game.incrementActCount(roomName);
      // Provider.of<GameDataProvider>(context, listen: false).incrementActCount;
      print(
          'должно быть около трех count после добавления${Provider.of<GameDataProvider>(context, listen: false).actCount}');

      difference = countCardsOnHand - 7;
      print('передали провайдеру разницу от 7 $difference');
      Provider.of<DiscardCardProvider>(context, listen: false)
          .updateDiscardCard(difference);

      await DialogWindow.show(
        context,
        'You have more than 7 cards in your hand, discard $difference and pass the turn',
        'Notification',
      );
    }
  }

  static Future<void> checkVictoryConditions(
    String roomName,
    currentPlayer,
  ) async {
    List<CardModel>? unicornsOnStall = await PlayerState.getPlayerDeck(
      roomName,
      'stall',
      currentPlayer,
    );
    int countUnicorns = unicornsOnStall?.length ?? 0;

    if (countUnicorns >= 7) {
      await Game.changeWinner(
        currentPlayer,
        roomName,
      );

      await Game.changeGameStatus('finished', roomName);
    }
  }

  static Future<void> exitGame(String roomName) async {
    await changeGameStatus('finished', roomName);
    SystemNavigator.pop();
  }

  static Future<void> statusGameAction(
    BuildContext context,
    String playersRoom,
    String myID,
    String otherID,
    String gameStatus,
    String currentPlayer,
    String gameWin,
    String? userNickname,
    String otherPlayer,
    String myEmail,
  ) async {
    bool isEven = gameWin.isNotEmpty ? true : false;
    if (gameStatus == 'checkTPRU' && currentPlayer == myID) {
      PlayerState.checkTPRU(
        context,
        currentPlayer,
        myID,
        otherID,
        playersRoom,
      );
    } else {
      String? gameWinner = myID == gameWin ? userNickname : otherPlayer;
      if (gameStatus == 'finished') {
        DialogForFinish.show(
          context,
          isEven
              ? 'Winner $gameWinner,would you like to play again? '
              : 'No winner found, would you like to play again?',
          'Game over',
          myEmail,
          myID,
          playersRoom,
        );
      }
    }
  }
}

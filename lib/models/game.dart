import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/player.dart';
import 'package:unstable_unicorns/models/player_state.dart';

import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/game_play_out_card_status_provider.dart';

import '../provider/current_player_provider.dart';
import '../services/dialog/dialog_for_finish.dart';
import '../services/dialog/dialog_window.dart';
import '../services/snack_bar.dart';
import 'card.dart';

class Game {
  bool openDialog = false;

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

    await roomRef2.update({
      'currentTurn': players.first,
    });

    await roomRef2.collection('GameState').doc('state').set({
      'deck': [],
      'discardPile': [],
      'playingCardOnTable': [],
    });

    await roomRef2.collection('GameCardStatus').doc('state').set({
      'gameCardStatus': 'nothing',
    });




    for (String playerID in players) {
      await PlayerState.setPlayerState(roomName, playerID);
    }

    await roomRef2.update({
      'gameStatus': 'inProcess',
    });

    await roomRef2.collection('action').doc('state').set({
      'actCount': 0,
      'lastActive': FieldValue.serverTimestamp(),
    });

    await roomRef2.collection('cardAction').doc('state').set({
      'cardAction': 0,
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

  // static Future<void> spentMessage(
  //     String currentPlayer, String roomName, String actionType) async {
  //   final roomRef = FirebaseFirestore.instance
  //       .collection(roomName)
  //       .doc('room')
  //       .collection('message')
  //       .doc('action')
  //       .update({
  //     'actionType': actionType,
  //     'playerId': currentPlayer,
  //     'lastActive': FieldValue.serverTimestamp(),
  //   });
  // }
  //
  static Future<void> changeGameStatus(
    String gameStatus,
    String roomName,
  ) async {
    final roomRef =
        FirebaseFirestore.instance.collection(roomName).doc('room')
            .update({
      'gameStatus': gameStatus,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> getGameStatus(String roomName) async {
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection(roomName).doc('room')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('gameStatus')) {
        String gameStatus = data['gameStatus'] ?? '';
        return gameStatus;
      }
    }
  }

  static Future<void> updateGameCardStatus(
      String roomName,
      String newStatus,
      ) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameCardStatus')
        .doc('state')
        .update({
      'gameCardStatus': newStatus,
    });
  }

  static Future<String?> getGameCardStatus(
      String roomName,
      ) async {
    final roomRef = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameCardStatus')
        .doc('state')
        .get();
    if (roomRef.exists) {
      Map<String, dynamic>? data = roomRef.data();

      if (data != null && data.containsKey('gameCardStatus')) {
        String gameCardStatus = data['gameCardStatus'] ?? '';
        return gameCardStatus;
      }
    }
  }

  static Future<void> cleanActCount(
    String roomName,
  ) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('action')
        .doc('state')
        .update({
      'actCount': 0,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateActCount(
    String roomName,
    int newCount,
  ) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('action')
        .doc('state')
        .update({
      'actCount': newCount,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<int?> getActCount(
    String roomName,
  ) async {
    final roomRef = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('action')
        .doc('state')
        .get();
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
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('action')
        .doc('state')
        .update({
      'actCount': actCount + 1,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> cleanCardAction(
    String roomName,
  ) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('cardAction')
        .doc('state')
        .update({
      'cardAction': 0,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateCardAction(
    String roomName,
    int newCount,
  ) async {
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('cardAction')
        .doc('state')
        .update({
      'cardAction': newCount,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<int?> getCardAction(
    String roomName,
  ) async {
    final roomRef = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('cardAction')
        .doc('state')
        .get();
    if (roomRef.exists) {
      Map<String, dynamic>? data = roomRef.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('cardAction')) {
        int cardAction = data['cardAction'] ?? '';
        return cardAction;
      }
    }
  }

  static Future<void> incrementCardAction(
    String roomName,
  ) async {
    int? actCount = await getCardAction(roomName) ?? 0;
    final roomRef = FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('cardAction')
        .doc('state')
        .update({
      'cardAction': actCount + 1,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> changeWinner(
    String currentPlayer,
    String roomName,
  ) async {
    final roomRef =
        FirebaseFirestore.instance.collection(roomName).doc('room')
            .update({
      'gameWin': currentPlayer,
      // 'lastActive': FieldValue.serverTimestamp(),
    });
  }



  static Future<void> updatePlayOutCard(String roomName, CardModel? cards) async {
    Map<String, dynamic>? newCardMaps = cards?.toMap();

    await FirebaseFirestore.instance.collection(roomName).doc('room').update({
      'drawCard': newCardMaps,
    });
    print('сейчас обновляю игровую карту');}

  static Future<CardModel?> getPlayOutCard(String roomName) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection(roomName).doc('room').get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('drawCard')) {
        var drawCardData = data['drawCard'];

        if (drawCardData is Map<String, dynamic>) {
          return CardModel.fromMap(drawCardData);
        } else {
          print('Разыгрываемая карта не имеет корректного формата');
          return null; // Неверный формат данных
        }
      } else {
        print('Поле drawCard не найдено');
        return null; // Поле не найдено
      }
    }
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
    List<CardModel>? cardsOnHand = await PlayerState.getPlayerDeck(
      roomName,
      typeDeck,
      currentPlayer,
    );
    int countCardsOnHand = cardsOnHand?.length ?? 0;
    int difference = 0;

    if (countCardsOnHand >= 0 && countCardsOnHand <= 7) {
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
    } else {
      await Game.incrementActCount(roomName);

      difference = countCardsOnHand - 7;
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
      {bool openDialog = false}) async {
    bool isEven = gameWin.isNotEmpty ? true : false;
    if (gameStatus == 'checkTPRU' && currentPlayer == myID) {
      Player.checkTPRU(
        context,
        currentPlayer,
        myID,
        otherID,
        playersRoom,
      );

      if (currentPlayer != myID) {
          SnackBarService.showSnackBar(context, 'Player $otherPlayer makes a move', false);
        }
    } else if (gameStatus == 'finished') {
      String? gameWinner = myID == gameWin ? userNickname : otherPlayer;

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

    }else if (gameStatus == 'playOutSpell' && myID == Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer) {
        print('тулущий игрок через куррент $currentPlayer');
        print('тулущий игрок через провайдер ${Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer}');
        CardModel? card = await Game.getPlayOutCard(playersRoom);

        print('разыгрываемая карта в статус гейм ${card?.name}');
if(card != null){
  await CardModel.playOutSpell(context, playersRoom, card, myID, otherID);
} else{
  print('равно нулю разыгрываемая карта');
}
        // }
      // }
    }
  }
}

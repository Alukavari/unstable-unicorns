import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import 'package:unstable_unicorns/widgets/game_board.dart';
import '../const/const.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game.dart';

class GameConsoleScreen extends StatefulWidget {
  final String playersRoom;
  final String? userNickname;

  const GameConsoleScreen({
    super.key,
    required this.userNickname,
    required this.playersRoom,
  });

  @override
  State<GameConsoleScreen> createState() => _GameConsoleScreenState();
}

class _GameConsoleScreenState extends State<GameConsoleScreen> {
  String otherPlayer = '';
  String playerID1 = '';
  String playerID2 = '';
  List <CardModel> uniDeck = [];
  List<CardModel> deck = [];

  Future<void> _getPlayerHashcode(String nameCollection) async {
    final roomRef = FirebaseFirestore.instance
        .collection(widget.playersRoom)
        .doc(nameCollection);
    final roomData = await roomRef.get();
    if (!roomData.exists) {
      return;
    } else {
      if (roomData.data()?['user_nickname'] == widget.userNickname) {
        setState(() {
          playerID1 = roomData.data()!['playerID'].toString();
        });
      } else {
        setState(() {
          playerID2 = roomData.data()!['playerID'].toString();
        });
      }
    }
  }

  Future<void> _getNicknameOpponent() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.playersRoom)
          .where('user_nickname', isNotEqualTo: widget.userNickname)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          otherPlayer = snapshot.docs.first['user_nickname'];
        });
      } else {
        otherPlayer = 'User2';
      }
    } catch (e) {
      SnackBarService.showSnackBar(
          context, 'Error fetching other player name: $e', true);
    }
  }

  Future<void> _initializeGame() async {
    await _getNicknameOpponent();
    await _getPlayerHashcode('player1');
    await _getPlayerHashcode('player2');
    if (otherPlayer.isNotEmpty &&
        playerID1.isNotEmpty &&
        playerID2.isNotEmpty) {

      await Game.startGame(widget.playersRoom, playerID2, playerID1);
      await Deck.updateDeck(widget.playersRoom, deck);
      await Game.drawnCards(widget.playersRoom, context, uniDeck, deck, 5, playerID1, playerID2);
    }
  }

  @override
  void initState() {
    super.initState();
    deck.addAll(cards);
    uniDeck.addAll(babyDeck);
    _initializeGame();
    _getNicknameOpponent();
  }

  @override
  Widget build(BuildContext context) {
    return GameBoard(otherPlayer: otherPlayer, userNickname: widget.userNickname);
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../const/colors.dart';
import '../const/const.dart';
import '../models/game.dart';
import '../services/current_player_provider.dart';

class ButtonChange extends StatefulWidget {
  final String roomName;
  final String myID;
  final String otherID;
  final String title = 'Your turn';
  final String title2 = 'Wait..';


  const ButtonChange({
    super.key,
    required this.myID,
    required this.otherID,
    required this.roomName,

  });

  @override
  State<ButtonChange> createState() => _ButtonChangeState();
}

class _ButtonChangeState extends State<ButtonChange> {

  String currentPlayer ='';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String newPlayer = Provider.of<CurrentPlayerState>(context).currentPlayer;
    if (newPlayer.isNotEmpty) {
      setState(() {
        currentPlayer = newPlayer; // Обновляем состояние
      });
    }
  }

  Future<void> nextCurrentPlayer() async {
    final roomRef =
        FirebaseFirestore.instance.collection(widget.roomName).doc('room');

    String nextPlayer =
        (currentPlayer == widget.myID) ? widget.otherID : widget.myID;
    print(
        'мы на баттон таймер меняем пользователя $currentPlayer and $nextPlayer');

    await roomRef.update({
      'currentTurn': nextPlayer,
      'lastActive': FieldValue.serverTimestamp(),
    });

    setState(() {
      currentPlayer = nextPlayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMyTurn = currentPlayer == widget.myID;


    return Align(
      alignment: Alignment.topRight,
      child: ElevatedButton(
        onPressed: isMyTurn
            ? () {
                nextCurrentPlayer();
              }
            : null,
        style: ElevatedButton.styleFrom(
            foregroundColor: bgColor,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(
            isMyTurn
                ? widget.title
                : widget.title2,
            style: textForScroll),
      ),
    );
  }
}

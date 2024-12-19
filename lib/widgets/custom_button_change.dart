import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import '../const/colors.dart';
import '../const/const.dart';
import '../models/game.dart';
import '../provider/current_player_provider.dart';

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
  String currentPlayer = '';


  Future<void> _onHandTap() async {

    print('мы на кнопке, должно быть либо 2,3 $count');

    bool isEven = Provider.of<GameDataProvider>(context, listen: false).actCount >= 2
        ? true
        : false;

    if(isEven){
      await Game.checkCountCardOnHand(
        context,
        widget.roomName,
        'hand',
        currentPlayer,
        widget.myID,
        widget.otherID,
      );
      // await Game.checkVictoryConditions(
      //     widget.roomName,
      //     currentPlayer
      // );

    } else{
      DialogWindow.show(
        context,
        'You didn\'t make a move',
        'Notification',
      );
    }
    // isEven
    //     ? await Game.checkCountCardOnHand(
    //     context,
    //     widget.roomName,
    //     'hand',
    //     currentPlayer,
    //     widget.myID,
    //     widget.otherID,
    // )
    //     : DialogWindow.show(
    //         context,
    //         'You didn\'t make a move',
    //         'Notification',
    //       );
    // //
    // await Game.checkVictoryConditions(
    //     widget.roomName,
    //     currentPlayer
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    String newPlayer = Provider.of<CurrentPlayerState>(context).currentPlayer;
    if (newPlayer.isNotEmpty) {
      setState(() {
        currentPlayer = newPlayer; // Обновляем состояние
      },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyTurn = currentPlayer == widget.myID;

    return Align(
      alignment: Alignment.topRight,
      child: ElevatedButton(
        onPressed: isMyTurn
            ? () async {
                _onHandTap();
              }
            : null,
        style: ElevatedButton.styleFrom(
            foregroundColor: bgColor,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child:
            Text(isMyTurn ? widget.title : widget.title2, style: textForScroll),
      ),
    );
  }
}

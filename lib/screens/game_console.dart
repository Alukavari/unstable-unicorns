import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import '../const/const.dart';
import '../services/db_game_helper.dart';

class GameConsoleScreen extends StatefulWidget {
  final String playersRoom;
  final String? userNickname;

  const GameConsoleScreen(
      {super.key,
      required this.userNickname,
      required this.playersRoom,
      });

  @override
  State<GameConsoleScreen> createState() => _GameConsoleScreenState();
}

class _GameConsoleScreenState extends State<GameConsoleScreen> {
  String otherPlayer = '';
  String playerID1 ='';
  String playerID2 ='';


  Future<void> _getPlayerHashcode(String nameCollection)async{
    final roomRef = FirebaseFirestore.instance.collection(widget.playersRoom).doc(nameCollection);
    final roomData = await roomRef.get();
    if(!roomData.exists){
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

    // Ждать, пока не получим ник другого игрока
    // Убедиться, что другой игрок не пустой
    if (otherPlayer.isNotEmpty && playerID1.isNotEmpty && playerID2.isNotEmpty) {
      await DB.startGame(widget.playersRoom,playerID2, playerID1);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeGame();_getNicknameOpponent();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          foregroundImage: AssetImage('assets/suit.png'),
                        ),
                        const SizedBox(height: 5),
                        Text(otherPlayer, style: textBoldWhite),
                      ],
                    ),
                    const SizedBox(width: 20),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('files', style: textBoldWhite),
                    const SizedBox(width: 20),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // children: [CardGridView(cards: otherPlayerFiles)]),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('bonuses', style: textBoldWhite),
                    const SizedBox(width: 10),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // children: CardGridView(cards: otherPlayerBonuses),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.asset(''
                          'assets/suit.png'),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset(''
                            'assets/1ff.png'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: Image.asset(''
                          'assets/1b.png'),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('bonuses', style: textBoldWhite),
                    const SizedBox(width: 10),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // children: [CardGridView(cards: myBonuses)],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('files', style: textBoldWhite),
                    const SizedBox(width: 10),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // children: [CardGridView(cards: myFiles)],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Column(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          foregroundImage: AssetImage('assets/suit.png'),
                        ),
                        const SizedBox(height: 5),
                        Text('${widget.userNickname}', style: textBoldWhite),
                      ],
                    ),
                    const SizedBox(width: 20),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // child: CardGridView(cards: myStall)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // children: [CardGridView(cards: myCard)],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

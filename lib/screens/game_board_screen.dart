import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../const/const.dart';
import 'game_console.dart';

class GameBoardScreen extends StatefulWidget {
  final String playersRoom;
  final String userNickname;

  const GameBoardScreen(
      {super.key, required this.playersRoom, required this.userNickname});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  bool _isReady = false;

  Future<void> _updateGameStatus() async {
    await FirebaseFirestore.instance
        .collection(widget.playersRoom)
        .doc('player1')
        .set({
      'playerReady': FieldValue.arrayUnion([widget.userNickname])
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _updateGameStatus();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference gameStatusRef = FirebaseFirestore.instance
        .collection(widget.playersRoom)
        .doc('player1');

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: gameStatusRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // Проверяем, что данные доступны
          if (!snapshot.hasData || snapshot.data == null) {
            print('error');
          }
          // Получаем статус готовности двух игроков
          final data = snapshot.data?.data() as Map<String, dynamic>;
          if (!data.containsKey('playerReady')) {
            return const Center(child: Text('No players ready status found'));
          }
          final playerReadyList = data['playerReady'] as List;

          if (playerReadyList.contains(widget.userNickname)) {
            _isReady = true;
            print('playerReadyList ${playerReadyList.length}');
          }

          // Проверяем, готовы ли оба игрока начать игру
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isReady && playerReadyList.length == 2) {
              print('playerReadyList 2 ${playerReadyList.length}');
              // Перенаправление на игру
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameConsoleScreen(
                    userNickname: widget.userNickname,
                    playersRoom: widget.playersRoom,
                  ),
                ),
              );
            }
          });
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Waiting for another player...',
                    style: textBold, textAlign: TextAlign.center),
                if (!_isReady)
                  TextButton(
                    onPressed: () async {
                      await _updateGameStatus();
                    },
                    child: Text('Start Game', style: textBoldUnderline),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

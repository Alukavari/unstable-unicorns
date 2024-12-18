import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/services/dialog_for_finish.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import 'package:unstable_unicorns/widgets/custom_button_change.dart';
import 'package:unstable_unicorns/widgets/discard_pile_widget.dart';
import 'package:unstable_unicorns/widgets/hand_card_widget.dart';
import 'package:unstable_unicorns/widgets/my_bonuses_fines.dart';
import 'package:unstable_unicorns/widgets/my_stall_widget.dart';
import 'package:unstable_unicorns/widgets/other_bonuses_fines.dart';
import 'package:unstable_unicorns/widgets/other_stall_widget.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game.dart';
import '../models/game_state.dart';
import '../models/player_state.dart';
import '../provider/current_player_provider.dart';
import '../widgets/card_on_table_widget.dart';
import '../widgets/deck_widget.dart';

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
  bool isInitialized = false;
  bool isPlayerTurn = true;

  String otherPlayer = '';
  String myID = '';
  String otherID = '';
  String myEmail = '';

  List<CardModel> uniDeck = [];
  List<CardModel> allDeck = [];
  String currentPlayer = '';
  int countTakeCards = 1; //поменяли
  List<CardModel> discardPile = [];
  List<CardModel> playingCardOnTable = [];

  Future<void> _getPlayerHashcode() async {
    final roomRef = FirebaseFirestore.instance.collection(widget.playersRoom);

    final roomData = await roomRef.doc('player1').get();

    final roomData2 = await roomRef.doc('player2').get();

    if (!roomData.exists || !roomData2.exists) {
      return;
    } else {
      if (roomData.data()?['user_nickname'] == widget.userNickname &&
          roomData2.data()?['user_nickname'] != widget.userNickname) {
        setState(() {
          myID = roomData.data()!['playerID'].toString();
          otherID = roomData2.data()!['playerID'].toString();
        });
      } else {
        setState(() {
          myID = roomData2.data()!['playerID'].toString();
          otherID = roomData.data()!['playerID'].toString();
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
    print('начало инициализации');
    await _getNicknameOpponent();
    await _getPlayerHashcode();
    if (otherPlayer.isNotEmpty && myID.isNotEmpty && otherID.isNotEmpty) {
      await Game.startGame(widget.playersRoom, otherID, myID);
      await GameState.updateDeck(widget.playersRoom, allDeck);
      await PlayerState.drawnCards(
          widget.playersRoom, context, uniDeck, allDeck, 5, myID, otherID);
      currentPlayer = await Game.currentPlayer(widget.playersRoom);
      myEmail = await Game.getEmailByID(myID) ?? '';
    }
    print('конец инициализации');
  }

  @override
  void initState() {
    super.initState();
    allDeck.addAll(cards);
    uniDeck.addAll(babyDeck);
    _getNicknameOpponent();

    if (!isInitialized) {
      _initializeGame();
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (otherID.isEmpty && myID.isEmpty && currentPlayer.isEmpty) {
      return Container();
    }

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    //stall
                    Expanded(
                      child: StallWidget(
                          otherPlayer: otherPlayer,
                          otherID: otherID,
                          roomName: widget.playersRoom),
                    ),
                    //button
                    const SizedBox(height: 10),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('action')
                            .doc('state')
                            .snapshots(),
                        builder: (context, snapshot) {
                          // if(snapshot.hasError){
                          //   print('ошибка в стриме с аксткаунт');
                          //   return const SizedBox.shrink();
                          // }
                          // if (!snapshot.hasData) {
                          //   return const SizedBox.shrink();
                          // }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return const SizedBox.shrink();
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              !snapshot.data!.exists) {
                            return const SizedBox.shrink();
                          }
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>;

                          int actCount = data['actCount'] ?? 0;
                          print('actCount $actCount');

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Provider.of<GameDataProvider>(context,
                                listen: false)
                                .updateActCount(actCount);
                          });
                          return const SizedBox.shrink();
                        }),

                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>;

                          String currentPlayer = data['currentTurn'] ?? '';
                          String gameStatus = data['gameStatus'];
                          String gameWin = data['gameWin'];
                          bool isEven = gameWin.isNotEmpty ? true : false;
                          print('победитель $gameWin');

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Provider.of<CurrentPlayerState>(context,
                                    listen: false)
                                .updateCurrentPlayer(currentPlayer);
                          });

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (gameStatus == 'checkTPRU' &&
                                currentPlayer == myID) {
                              PlayerState.checkTPRU(
                                context,
                                currentPlayer,
                                myID,
                                otherID,
                                widget.playersRoom,
                              );
                            } else {
                              String? gameWinner = myID == gameWin
                                  ? widget.userNickname
                                  : otherPlayer;
                              if (gameStatus == 'finished') {
                                DialogForFinish.show(
                                  context,
                                  isEven
                                      ? 'Winner $gameWinner,would you like to play again? '
                                      : 'No winner found, would you like to play again?',
                                  'Game over',
                                  myEmail,
                                  myID,
                                  widget.playersRoom,
                                );
                              }
                            }
                          });
                          print('получили дату из провайдера $currentPlayer');
                          return Align(
                            alignment: Alignment.topRight,
                            child: ButtonChange(
                              myID: myID,
                              otherID: otherID,
                              roomName: widget.playersRoom,
                            ),
                          );
                        }),
                  ],
                ),
                const SizedBox(height: 10),
                // other bonuses and fines
                Row(
                  children: [
                    Expanded(
                      child: OtherBonusesFines(
                        roomName: widget.playersRoom,
                        otherPlayer: otherPlayer,
                        otherID: otherID,
                        myID: myID,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // playing board
                Row(
                  children: [
                    //deck
                    BuildDeckWidget(
                        roomName: widget.playersRoom,
                        myID: myID,
                        countTakeCards: countTakeCards),
                    const SizedBox(width: 10),
                    //on table
                    Expanded(
                      child: BuildOnTableWidget(
                        roomName: widget.playersRoom,
                        // ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    //discard pile
                    SizedBox(
                      width: 110,
                      height: 170,
                      child: BuildDiscardPileWidget(
                        roomName: widget.playersRoom,
                        myID: myID,
                        countTakeCards: countTakeCards,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                //my bonus and fines
                Row(
                  children: [
                    Expanded(
                      child: MyBonusesFines(
                        roomName: widget.playersRoom,
                        otherPlayer: otherPlayer,
                        otherID: otherID,
                        myID: myID,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //my stall
                Row(
                  children: [
                    Expanded(
                      child: MyStallWidget(
                        roomName: widget.playersRoom,
                        otherPlayer: otherPlayer,
                        otherID: otherID,
                        myID: myID,
                        userNickname: widget.userNickname,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // hand
                Row(
                  children: [
                    Expanded(
                      child: HandCardWidget(
                        roomName: widget.playersRoom,
                        otherID: otherID,
                        myID: myID,
                      ),
                    )
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import 'package:unstable_unicorns/widgets/scroll_widget.dart';
import '../const/const.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game.dart';
import '../services/dialog_for_deck.dart';
import '../widgets/scroll_widget_trim.dart';

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
  String otherPlayer = '';
  String playerID1 = '';
  String playerID2 = '';
  List<CardModel> uniDeck = [];
  List<CardModel> deck = [];
  String currentPlayer = '';
  int count = 0;
  int countTakeCards = 1;

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
    count++;
    print("count = $count");

    await _getNicknameOpponent();
    await _getPlayerHashcode('player1');
    await _getPlayerHashcode('player2');
    if (otherPlayer.isNotEmpty &&
        playerID1.isNotEmpty &&
        playerID2.isNotEmpty ) {
      await Game.startGame(widget.playersRoom, playerID2, playerID1);
      await Deck.updateDeck(widget.playersRoom, deck);
      await Game.drawnCards(
          widget.playersRoom, context, uniDeck, deck, 5, playerID1, playerID2);
      currentPlayer = await Game.currentPlayer(widget.playersRoom);
    }
  }

  @override
  void initState() {
    super.initState();
    deck.addAll(cards);
    uniDeck.addAll(babyDeck);
    _getNicknameOpponent();
    if (!isInitialized) {
      _initializeGame();
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (playerID2.isEmpty && playerID1.isEmpty) {
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
                    //stall
                    if (playerID2.isNotEmpty) ...[
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('GameState')
                            .doc('state')
                            .collection('playersState')
                            .doc(playerID2)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists ||
                              snapshot.data == null) {
                            return const CircularProgressIndicator();
                          } else {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            var cardList = data['stall'] as List? ?? [];
                            if (cardList.isEmpty) {
                              return Container();
                            }

                            List<CardModel> cards = cardList.map((cardData) {
                              return CardModel.fromMap(cardData);
                            }).toList();

                            return Expanded(
                              child: SizedBox(
                                height: 170,
                                child: ScrollWidget(cards: cards),
                              ),
                            );
                            // children: [ScrollWidget(cards: cards)]));
                          }
                        },
                      ),
                    ],
                  ],
                ),
                //fines
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('fines', style: textBoldWhite),
                    const SizedBox(width: 10),
                    if (playerID2.isNotEmpty) ...[
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('GameState')
                            .doc('state')
                            .collection('playersState')
                            .doc(playerID2)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists ||
                              snapshot.data == null) {
                            return Container();
                          } else {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            var cardList = data['fines'] as List? ?? [];
                            if (cardList.isEmpty) {
                              return Container();
                            }

                            List<CardModel> cards = cardList.map((cardData) {
                              return CardModel.fromMap(cardData);
                            }).toList();

                            return Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ScrollWidgetTrim(cards: cards),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),
                //bonuses
                Row(
                  children: [
                    Text('bonuses', style: textBoldWhite),
                    const SizedBox(width: 10),
                    if (playerID2.isNotEmpty) ...[
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('GameState')
                            .doc('state')
                            .collection('playersState')
                            .doc(playerID2)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              !snapshot.data!.exists) {
                            return Container();
                          } else {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            var cardList = data['bonuses'] as List? ?? [];
                            if (cardList.isEmpty) {
                              return Container();
                            }

                            List<CardModel> cards = cardList.map((cardData) {
                              return CardModel.fromMap(cardData);
                            }).toList();

                            return Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ScrollWidgetTrim(cards: cards),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),
                //player board
                // StreamBuilder<DocumentSnapshot>(
                //   stream: FirebaseFirestore.instance
                //       .collection(widget.playersRoom)
                //       .doc('room')
                //       .collection('GameState')
                //       .doc('state')
                //       .snapshots(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator();
                //     } else if (snapshot.hasError) {
                //       return Container();
                //     } else if (!snapshot.hasData ||
                //         snapshot.data == null ||
                //         !snapshot.data!.exists) {
                //       return const CircularProgressIndicator();
                //     } else {
                //       var data = snapshot.data!.data() as Map<String, dynamic>;
                //
                //       var cardList = data['deck'] as List? ?? [];
                //       if (cardList.isEmpty) {
                //         return Container();
                //       }
                //       List<CardModel> deck = cardList.map((cardData) {
                //         return CardModel.fromMap(cardData);
                //       }).toList();
                //
                //
                //       var cardDiscardPile = data['discardPile'] as List;
                //       var cardListDiscardPile = data['discardPile'] as List? ?? [];
                //       if (cardList.isEmpty) {
                //         return Container();
                //       }
                //       List<CardModel> discardPile = cardList.map((cardData) {
                //         return CardModel.fromMap(cardData);
                //       }).toList();
                //
                //       var dataPlayingCardOnTable = data['playingCardOnTable'] as List? ?? [];
                //       if (cardList.isEmpty) {
                //         return Container();
                //       }
                //       List<CardModel> playingCardOnTable =
                //           cardList.map((cardData) {
                //         return CardModel.fromMap(cardData);
                //       }).toList();
                //       return SizedBox(
                //         height: 170,
                //         child: Center(
                //           child: Row(
                //             children: [
                //               GestureDetector(
                //                 onTap: () {
                //                   DialogForDeck.show(context, countTakeCards, 'Add this card', deck, widget.playersRoom, 'hand', 'deck', currentPlayer);
                //                 },
                //                 child: ClipRRect(
                //                   borderRadius: BorderRadius.circular(10),
                //                   child: Image.asset('assets/suit.png'),
                //                 ),
                //               ),
                //               const SizedBox(width: 5),
                //
                //               // Expanded(
                //               //   child: Padding(
                //               //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //               //     child: Center(
                //               //       child: Image.asset(''
                //               //           'assets/1ff.png'),
                //               //     ),
                //               //   ),
                //               // ),
                //               const SizedBox(width: 5),
                //
                //               // SizedBox(
                //               //   width: 110,
                //               //   child: GestureDetector(
                //               //     onTap: () {
                //               //       DialogForDeck.show(context, countTakeCards, 'choose a card', discardPile, widget.playersRoom, 'hand', 'discardPile', currentPlayer);
                //               //     },
                //               //     child: ClipRRect(
                //               //       borderRadius: BorderRadius.circular(10),
                //               //       child: Image.asset(discardPile.last.imageUrl),
                //               //     ),
                //               //   ),
                //               // )
                //             ],
                //           ),
                //         ),
                //       );
                //     }
                //   },
                // ),

                const SizedBox(height: 10),
// bonuses
                Row(
                  children: [
                    Text('bonuses', style: textBoldWhite),
                    const SizedBox(width: 10),
                    if (playerID1.isNotEmpty) ...[
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('GameState')
                            .doc('state')
                            .collection('playersState')
                            .doc(playerID1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              !snapshot.data!.exists) {
                            return Container();
                          } else {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            var cardList = data['bonuses'] as List? ?? [];
                            if (cardList.isEmpty) {
                              return Container();
                            }

                            List<CardModel> cards = cardList.map((cardData) {
                              return CardModel.fromMap(cardData);
                            }).toList();

                            return Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ScrollWidgetTrim(cards: cards),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),
                //fines
                Row(
                  children: [
                    Text('fines', style: textBoldWhite),
                    const SizedBox(width: 10),
                    if (playerID1.isNotEmpty) ...[
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('GameState')
                            .doc('state')
                            .collection('playersState')
                            .doc(playerID1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              !snapshot.data!.exists) {
                            return Container();
                          } else {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            var cardList = data['fines'] as List? ?? [];
                            if (cardList.isEmpty) {
                              return Container();
                            }

                            List<CardModel> cards = cardList.map((cardData) {
                              return CardModel.fromMap(cardData);
                            }).toList();

                            return Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ScrollWidgetTrim(cards: cards),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // stall
                Row(children: [
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
                  if (playerID1.isNotEmpty) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(widget.playersRoom)
                          .doc('room')
                          .collection('GameState')
                          .doc('state')
                          .collection('playersState')
                          .doc(playerID1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Container();
                        } else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            !snapshot.data!.exists) {
                          return Container();
                        } else {
                          var data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          var cardList = data['stall'] as List? ?? [];
                          if (cardList.isEmpty) {
                            return Container();
                          }

                          List<CardModel> cards = cardList.map((cardData) {
                            return CardModel.fromMap(cardData);
                          }).toList();

                          return Expanded(
                            child: SizedBox(
                              height: 170,
                              child: ScrollWidget(cards: cards),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ]),

                const SizedBox(height: 10),
                // hand
                Row(
                  children: [
                    if (playerID1.isNotEmpty) ...[
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(widget.playersRoom)
                            .doc('room')
                            .collection('GameState')
                            .doc('state')
                            .collection('playersState')
                            .doc(playerID1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              !snapshot.data!.exists) {
                            return const CircularProgressIndicator();
                          } else {
                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            var cardList = data['hand'] as List? ?? [];
                            if (cardList.isEmpty) {
                              return Container();
                            }

                            List<CardModel> cards = cardList.map((cardData) {
                              return CardModel.fromMap(cardData);
                            }).toList();

                            return Expanded(
                              child: SizedBox(
                                height: 170,
                                child: ScrollWidget(cards: cards),
                              ),
                            );
                          }
                        },
                      ),
                    ],
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

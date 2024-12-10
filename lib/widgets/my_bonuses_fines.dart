import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/widgets/scroll_widget_bonuses.dart';

import '../const/const.dart';
import '../models/card.dart';
import '../models/game.dart';
import '../services/current_player_provider.dart';
import '../services/game_data_provider.dart';

class MyBonusesFines extends StatelessWidget {
  final String roomName;
  final String otherPlayer;
  final String otherID;
  final String myID;
  // final int actCount;

  MyBonusesFines(
      {super.key,
      required this.roomName,
      required this.otherPlayer,
      required this.otherID,
      required this.myID,
      // required this.actCount,
      });

  // Future<String> getCurrentPlayer() async {
  //   String player = await Game.currentPlayer(roomName);
  //   return player;
  // }
  List<CardModel> _bonuses =[];
  List<CardModel> _fines =[];

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<String>(
    //     future: getCurrentPlayer(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       } else if (snapshot.hasError) {
    //         print('Error: ${snapshot.error}');
    //         return const SizedBox.shrink();
    //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //         print('нет даты');
    //         return const SizedBox.shrink();
    //       }
    //       String currentPlayer = snapshot.data!;
    //       print(
    //           'currentPlayer мы получили его в my bonuses and fines $currentPlayer');
    GameDataProvider gameData = GameDataProvider();
    final currentPlayer = Provider
        .of<CurrentPlayerState>(context)
        .currentPlayer;
    final isMyTurn = currentPlayer == myID;

          return Column(
            children: [
              Row(
                children: [
                  Text('bonuses', style: textBoldWhite),
                  const SizedBox(width: 10),
                  if (myID.isNotEmpty) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(roomName)
                          .doc('room')
                          .collection('GameState')
                          .doc('state')
                          .collection('playersState')
                          .doc(myID)
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
                          if(_bonuses == cards){
                            return const SizedBox.shrink();
                          }
                          _bonuses = cards;

                          return Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ScrollWidgetBonuses(
                                cards: cards,
                                // actCount: actCount,
                                // currentPlayer: currentPlayer,
                                roomName: roomName,
                                myID: myID,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('fines', style: textBoldWhite),
                  const SizedBox(width: 10),
                  if (myID.isNotEmpty) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(roomName)
                          .doc('room')
                          .collection('GameState')
                          .doc('state')
                          .collection('playersState')
                          .doc(myID)
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

                          if(_fines == cards){
                            return const SizedBox.shrink();
                          }
                          _fines = cards;

                          return Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ScrollWidgetBonuses(
                                cards: cards,
                                // actCount: actCount,
                                // currentPlayer: currentPlayer,
                                roomName: roomName,
                                myID: myID,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          );
    //     },
    // );
  }
}

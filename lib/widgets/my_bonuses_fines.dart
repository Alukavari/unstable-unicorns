import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/widgets/scroll_widget_bonuses.dart';

import '../const/const.dart';
import '../models/card.dart';
import '../models/game.dart';
import '../provider/current_player_provider.dart';
import '../provider/game_data_provider.dart';

class MyBonusesFines extends StatelessWidget {
  final String roomName;
  final String otherPlayer;
  final String otherID;
  final String myID;

  MyBonusesFines({
    super.key,
    required this.roomName,
    required this.otherPlayer,
    required this.otherID,
    required this.myID,
  });

  List<CardModel> _bonuses = [];
  List<CardModel> _fines = [];

  bool _listEqual(List<CardModel> a, List<CardModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Container();
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      !snapshot.data!.exists) {
                    return Container();
                  } else {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    var cardList = data['bonuses'] as List? ?? [];
                    if (cardList.isEmpty) {
                      return Container();
                    }

                    List<CardModel> cards = cardList.map((cardData) {
                      return CardModel.fromMap(cardData);
                    }).toList();

                    if (cards.length != _bonuses.length ||
                        !_listEqual(_bonuses, cards)) {
                      _bonuses = cards;
                      print('бонусы ${_bonuses.length}');

                      return Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ScrollWidgetBonuses(
                            cards: cards,
                            roomName: roomName,
                            myID: myID,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
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

                        if (cards.length != _fines.length ||
                            !_listEqual(_fines, cards)) {
                          _fines = cards;
                          // print('штрафы перерисовываемся ${_fines.length}');

                          return Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ScrollWidgetBonuses(
                                cards: cards,
                                roomName: roomName,
                                myID: myID,
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  )
                ],
              ],
            ),
      ],
    );
  }
}

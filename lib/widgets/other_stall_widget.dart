import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/widgets/scroll_widget.dart';

import '../const/const.dart';
import '../models/card.dart';

class StallWidget extends StatelessWidget {
  final String roomName;
  final String otherPlayer;
  final String otherID;

  const StallWidget(
      {super.key,
      required this.otherPlayer,
      required this.otherID,
      required this.roomName});

  @override
  Widget build(BuildContext context) {
    if (otherID.isEmpty) {
      return Container();
    }
    return Row(
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
        if (otherID.isNotEmpty) ...[
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(roomName)
                .doc('room')
                .collection('GameState')
                .doc('state')
                .collection('playersState')
                .doc(otherID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError) {
                return Container();
              } else if (!snapshot.hasData ||
                  !snapshot.data!.exists ||
                  snapshot.data == null) {
                return const CircularProgressIndicator();
              } else {
                var data = snapshot.data!.data() as Map<String, dynamic>;

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
    );
  }
}

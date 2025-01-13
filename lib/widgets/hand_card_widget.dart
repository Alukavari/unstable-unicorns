import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_hand_card.dart';
import '../models/card.dart';


class HandCardWidget extends StatelessWidget {
  final String roomName;
  final String otherID;
  final String myID;

  const HandCardWidget({
    super.key,
    required this.roomName,
    required this.otherID,
    required this.myID,
  });


  @override
  Widget build(BuildContext context) {
    if (myID.isEmpty) {
      return Container();
    }
        return Row(
          children: [
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
                    return const CircularProgressIndicator();
                  } else {
                    var data = snapshot.data!.data() as Map<String, dynamic>;

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
                          child: ScrollHandCard(
                              cards: cards,
                              roomName: roomName,
                              myID: myID,
                              otherID: otherID,
                              // checkCount: checkCount
                          ),
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        );
  }
}

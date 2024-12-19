import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../const/const.dart';
import '../models/card.dart';
import '../provider/current_player_provider.dart';
import '../provider/game_data_provider.dart';
import 'card_widget.dart';

class BuildOnTableWidget extends StatelessWidget {
  final String roomName;

   BuildOnTableWidget({
    super.key,
    required this.roomName,

  });

  List<CardModel> _cards = [];

  bool _listEqual(List<CardModel> a, List<CardModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(roomName)
            .doc('room')
            .collection('GameState')
            .doc('state')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: textBoldWhite,
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(
                child: Text('No Exist', style: textBoldWhite));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          var dataOnTable = data['playingCardOnTable'] as List? ?? [];
          List<CardModel> cardsOnTable = dataOnTable.map((cardData) {
            return CardModel.fromMap(cardData);
          }).toList();
          // print('playingCardOnTable мы на стримбилде ${cardsOnTable.length}');

          if (_cards.length != cardsOnTable.length || !_listEqual(_cards,cardsOnTable)) {
            _cards = cardsOnTable;
            print('перерисовываем карты на столе _cards ${_cards.length}');

            // return Expanded(
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 170,
                child: Stack(
                  children: _cards.isNotEmpty
                      ? _cards
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key; // Индекс
                    var card = entry.value; // Карта
                    return Positioned(
                      left: index * 30,
                      child: CardWidget(card: card),
                    );
                  }).toList()
                      : [const SizedBox.shrink()],
                ),
              );
          }
          return const SizedBox.shrink();
        }
    );
  }
}

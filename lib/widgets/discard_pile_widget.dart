import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/widgets/card_widget.dart';
import '../const/const.dart';
import '../models/card.dart';
import '../provider/current_player_provider.dart';
import '../services/dialog_for_deck.dart';
import '../provider/game_data_provider.dart';

class BuildDiscardPileWidget extends StatelessWidget {
  final String roomName;
  final String myID;
  final int countTakeCards;

  BuildDiscardPileWidget({
    super.key,
    required this.roomName,
    required this.myID,
    required this.countTakeCards,
  });

  List<CardModel> _cards = [];

  void _handleTap(
    BuildContext context,
    List<CardModel> cards,
    int countTakeCards,
    String roomName,
    String currentPlayer,
  ) {
    print('сколько каунт в сбрсое ${Provider
        .of<GameDataProvider>(context, listen: false)
        .actCount}');
    if (Provider
        .of<GameDataProvider>(context, listen: false)
        .actCount == 3) {
      DialogForDeck.show(
          context,
          countTakeCards,
          'Add this card',
          roomName,
          cards,
          'hand',
          'deck',
          currentPlayer);
      print('на выполнении нажатия на сброс');
    }
  }

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
          return Center(child: Text('No Exist', style: textBoldWhite));
        }
        var dataPile = snapshot.data!.data() as Map<String, dynamic>;
        var cardListDataPile = dataPile['discardPile'] as List? ?? [];
        List<CardModel> cardsPile = cardListDataPile.map((cardData) {
          return CardModel.fromMap(cardData);
        }).toList();

        if (cardsPile.length != _cards.length ||
            !_listEqual(_cards, cardsPile)) {
          _cards = cardsPile;

          return Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 170,
              width: 110,
              child: Consumer<CurrentPlayerState>(
                builder: (context, currentPlayerState, child) {
                  final currentPlayer = currentPlayerState.currentPlayer;
                  final isMyTurn = currentPlayer == myID;

                  return GestureDetector(
                    onTap: isMyTurn
                        ? () =>
                        _handleTap(
                          context,
                          _cards,
                          countTakeCards,
                          roomName,
                          currentPlayer,
                        )
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: cardsPile.isNotEmpty
                          ? CardWidget(card: _cards.last)
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}

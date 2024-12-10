import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../const/const.dart';
import '../models/card.dart';
import '../services/current_player_provider.dart';
import '../services/dialog_for_deck.dart';
import '../services/game_data_provider.dart';

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
    GameDataProvider gameData,
    int countTakeCards,
    String roomName,
    String currentPlayer,
  ) {
    print('сколько каунт в сбрсое ${gameData.actCount}');
    if (gameData.actCount == 2) {
      DialogForDeck.show(context, countTakeCards, 'Add this card', roomName,
          cards, 'hand', 'deck', currentPlayer);
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

    // final GameDataProvider gameData = GameDataProvider();

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
        print('мы в cardsPile ${cardsPile.length}');

        if (cardsPile.length == _cards.length) {
          print('сброс и кардс одинаковые');
          return const SizedBox.shrink();
        }

        if (cardsPile.length != _cards.length ||
            !_listEqual(cardsPile, _cards)) {
          _cards = cardsPile;
          print('перерисовываемся до консьюмера сброс');
          return SizedBox(
            height: 170,
            width: 110,
            child: Consumer<CurrentPlayerState>(
              builder: (context, currentPlayerState, child) {
                final currentPlayer = currentPlayerState.currentPlayer;
                final isMyTurn = currentPlayer == myID;
                print('перерисовываем консьюмер сброс');

                return GestureDetector(
                  onTap: isMyTurn
                      ? () => _handleTap(
                            context,
                            _cards,
                    Provider.of<GameDataProvider>(context, listen: false),
                            countTakeCards,
                            roomName,
                            currentPlayer,
                          )
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: cardsPile.isNotEmpty
                        ? Image.asset(_cards.last.imageUrl, fit: BoxFit.cover)
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

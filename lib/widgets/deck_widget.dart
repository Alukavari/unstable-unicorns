import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import '../const/const.dart';
import '../models/card.dart';
import '../models/game.dart';
import '../services/dialog_for_deck.dart';
import '../services/dialog_window.dart';
import '../provider/game_data_provider.dart';


class BuildDeckWidget extends StatefulWidget {
  final String roomName;
  final String myID;
  final int countTakeCards;

  const BuildDeckWidget({
    super.key,
    required this.roomName,
    required this.myID,
    required this.countTakeCards
  });

  @override
  State<BuildDeckWidget> createState() => _BuildDeckWidgetState();
}

class _BuildDeckWidgetState extends State<BuildDeckWidget> {

  List<CardModel> _cards = [];

  Future<void> _handleTap(BuildContext context,
      List<CardModel> cards,
      int countTakeCards,
      String roomName,
      String currentPlayer,) async {

      if (cards.isNotEmpty) {
          if (Provider.of<GameDataProvider>(context, listen: false).actCount <= 1) {
            print('deck actCount в дек виджет через провайдер ${Provider.of<GameDataProvider>(context, listen: false).actCount}');
            DialogForDeck.show(
                context,
                countTakeCards,
                'Add this card',
                roomName,
                cards,
                'hand',
                'deck',
                currentPlayer);
            await Game.incrementActCount(roomName);
            // Provider.of<GameDataProvider>(context, listen: false).incrementActCount();
            // print('сколько каунт сейчас мы в дек виджет через провайдер ${Provider.of<GameDataProvider>(context, listen: false).actCount}');
          } else {
            DialogWindow.show(context,
                'You have already taken the card, change your turn', 'Ups..');
          }
      } else {
        await Game.checkVictoryConditions(
            widget.roomName,
            currentPlayer
        );
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
            .collection(widget.roomName)
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
          var data = snapshot.data!.data() as Map<String, dynamic>;
          var cardList = data['deck'] as List? ?? [];

          List<CardModel> newCards = cardList.map((cardData) {
            return CardModel.fromMap(cardData);
          }).toList();

          print('мы в дек ${newCards.length}');

          if (newCards.length != _cards.length ||
              !_listEqual(_cards, newCards)) {
            _cards = newCards;
          }

          return Consumer<CurrentPlayerState>(
              builder: (context, currentPlayerState, child) {
                final currentPlayer = currentPlayerState.currentPlayer;
                final isMyTurn = currentPlayer == widget.myID;

                return Column(
                  children: [
                    //deck
                    SizedBox(
                      width: 110,
                      height: 170,
                      child: GestureDetector(
                        onTap: isMyTurn
                            ? () =>
                            _handleTap(
                                context,
                                _cards,
                                widget.countTakeCards,
                                widget.roomName,
                                currentPlayer)
                            : () =>
                            DialogWindow.show(
                                context, 'Wait your turn', 'Ups..'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _cards.isEmpty
                            ? null
                          : Image.asset(
                              'assets/suit.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                );
              }
          );
        }
    );
  }
}





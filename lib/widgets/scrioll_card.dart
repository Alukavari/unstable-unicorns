import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import '../models/card.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../provider/current_player_provider.dart';
import '../services/dialog_window.dart';
import '../provider/draw_card_provider.dart';
import '../provider/game_data_provider.dart';

class ScrollCard extends StatelessWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  String otherID;

  ScrollCard({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.otherID,
  });

  Future<void> _handleTap(
    BuildContext context,
    CardModel newCard,
    String roomName,
    String currentPlayer,
  ) async {

    print('мы в скрол actCount ${ Provider.of<GameDataProvider>(context, listen: false).actCount}');

    List<CardModel> deckCard = await GameState.getDeck(roomName, 'deck');
    int countDeck = deckCard.length ?? 0;

    if(countDeck == 0 ){
      await Game.checkVictoryConditions(roomName, currentPlayer);
    }

    if(newCard.type == CardClass.tpru){
      print('тиа карты ${newCard.type}  и проверяемый тип ${CardClass.tpru}');
      DialogWindow.show(
          context, 'You can\'t play whoa, choose another card', 'Notification');
    } else if(Provider.of<GameDataProvider>(context, listen: false).actCount == 1) {
     await Game.updateDrawCard(
       roomName,
       newCard,
     );
     await Player.playCard(
       context,
       roomName,
       currentPlayer,
       myID,
       otherID,
     );
     await Game.incrementActCount(roomName);
     print('сколько теперь каунт потмоу что мы добавили1 ${Provider.of<GameDataProvider>(context, listen: false).actCount}');
   } else if (Provider.of<GameDataProvider>(context, listen: false).actCount== 0) {
     DialogWindow.show(context, 'Take a card from the deck', 'Notification');
   } else if (Provider.of<GameDataProvider>(context, listen: false).actCount == 2) {
     DialogWindow.show(
         context, 'You have finished change your turn', 'Notification');
   } else if (Provider.of<GameDataProvider>(context, listen: false).actCount >= 3) {
       if (Provider
           .of<DiscardCardProvider>(context, listen: false)
           .discardCard !=
           0) {
         await GameState.updateWithNewCardGameDeck(
             roomName, newCard, 'discardPile');
         await PlayerState.removeCardFromPlayerDeck(
             roomName, newCard, 'hand', currentPlayer);
         Provider.of<DiscardCardProvider>(context, listen: false)
             .decreaseDiscardCard();
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;
    final isMyTurn = currentPlayer == myID;

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards!.length,
      itemBuilder: (context, index) {
        return Container(
          width: 110,
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: isMyTurn
                ? () => _handleTap(
                      context,
                      cards![index],
                      roomName,
                      currentPlayer,
                    )
                : () {},
            onDoubleTap: () {
              DialogWindow.show(
                  context, cards![index].description, cards![index].name);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                cards![index].imageUrl,
                fit: BoxFit.cover,
                width: 110,
                height: 170,
              ),
            ),
          ),
        );
      },
    );
  }
}

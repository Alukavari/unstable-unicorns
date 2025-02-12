import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/const/text_for_check_dialog.dart';
import 'package:unstable_unicorns/models/chek_possibility.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/game_state.dart';
import '../../provider/current_player_provider.dart';
import '../../provider/game_data_provider.dart';
import '../../provider/play_out_card_provider.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollWidgetOtherBonuses extends StatelessWidget {
  List<CardModel> cards;
  String roomName;
  String myID;

  ScrollWidgetOtherBonuses({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
  });



  @override
  Widget build(BuildContext context) {

    final currentPlayer = Provider.of<CurrentPlayerState>(context).currentPlayer;
    final isMyTurn = currentPlayer == myID;

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
            onDoubleTap: () {
              DialogWindow.show(
                  context, cards[index].description, cards[index].name);
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  // color: Colors.white,
                  color: Colors.orangeAccent,
                  width: 80,
                  height: 30,
                  child: Center(child: Text(cards[index].name, style: textForFB, textAlign: TextAlign.center)),
                )

            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import '../models/card.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/player_state.dart';
import '../provider/current_player_provider.dart';
import '../provider/game_data_provider.dart';
import '../services/dialog_window.dart';

class ScrollForGame extends StatefulWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  int countDiscard;

  ScrollForGame({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.countDiscard,
  });

  @override
  State<ScrollForGame> createState() => _ScrollForGame();
}
class _ScrollForGame extends State<ScrollForGame> {

  int count = 0;

  void _onTap(
    BuildContext context,
    CardModel? card,
  ) async {
    if(count < widget.countDiscard) {
      await Player.cardDiscard(context, widget.roomName, card!, widget.myID);
      await Game.incrementCardAction(widget.roomName);
      print('сколько кардАктион ${Provider
          .of<ProgressCheckProvider>(context, listen: false)
          .check}');
      // Provider.of<ProgressCheckProvider>(context, listen:false).incrementCheck();
      count++;
    } else{
      Navigator.of(context).pop();// Закрываем диалог, если достигли лимита
    }
    print(' првоеряем сколько в провайдере чек после плюса текущего ${Provider.of<ProgressCheckProvider>(context, listen: false).check}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 110, //
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.cards!.length,
          itemBuilder: (context, index) {
            return Container(
              width: 110,
              margin: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () {
                    _onTap(context, widget.cards![index]);
                },
                onDoubleTap: () {
                  DialogWindow.show(
                      context, widget.cards![index].description, widget.cards![index].name);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.cards![index].imageUrl,
                      fit: BoxFit.contain
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


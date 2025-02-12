import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/deck.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollForMultiDiscard extends StatefulWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  int countDestroy;


  ScrollForMultiDiscard({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.countDestroy,
  });

  @override
  State<ScrollForMultiDiscard> createState() => _ScrollForMultiDiscard();

}
class _ScrollForMultiDiscard extends State<ScrollForMultiDiscard> {
  int count = 0;
  List<CardModel>?  destroyCards = [];

  @override
  void initState() {
    super.initState();
    destroyCards= List.from(widget.cards!);
  }


  Future<void> _onTap(
      BuildContext context,
      CardModel card,
      ) async {
    print('на скролле для множественного сброса');

    if(count < widget.countDestroy) {
      await Player.cardDiscard(context, widget.roomName, card, widget.myID);
      setState(() {
        destroyCards?.remove(card); // Удаляем уничтоженную карту
      });
      await Game.incrementCardAction(widget.roomName);
      count++;
      if(count >= widget.countDestroy ){
        await Game.cleanCardAction(widget.roomName);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 110, //
        child: SingleChildScrollView(
        child: Column(
        children: List.generate(destroyCards!.length ?? 0, (index) {
        // child: ListView.builder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: destroyCards?.length,
        //   itemBuilder: (context, index) {
            return Container(
              width: 110,
              margin: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () async {
                  _onTap(context, destroyCards![index]);
                },
                onDoubleTap: () {
                  DialogWindow.show(context, destroyCards![index].description, destroyCards![index].name);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                      destroyCards![index].imageUrl,
                      fit: BoxFit.contain
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
        //add
    ),
    );
    //add
  }
}


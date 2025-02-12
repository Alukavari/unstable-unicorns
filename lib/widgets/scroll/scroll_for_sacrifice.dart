import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/deck.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollForSacrifice extends StatefulWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  int countDiscard;


  ScrollForSacrifice({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.countDiscard,
  });

  @override
  State<ScrollForSacrifice> createState() => _ScrollForSacrifice();

}
class _ScrollForSacrifice extends State<ScrollForSacrifice> {
  int count = 0;

  void _onTap(
      BuildContext context,
      CardModel? card,
      ) async {
    print('на скролле для принесения в жертву');

    if(count < widget.countDiscard) {
      if(
      card?.type == CardClass.bonus){
        await Player.sacrificeBonus(card, widget.roomName, widget.myID);

      } else if(
      card?.type == CardClass.unicorn || card?.type == CardClass.baby){
        await Player.sacrificeUnicorn(context, widget.roomName, card, widget.myID);
      } else if(
      card?.type == CardClass.fine){
        await Player.sacrificeFines(card, widget.roomName, widget.myID);
      }

      await Game.incrementCardAction(widget.roomName);
      count++;
      if(count >= widget.countDiscard ){
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
        children: List.generate(widget.cards?.length ?? 0, (index) {
        // child: ListView.builder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   // itemCount: cards.length,
        //   itemCount: widget.cards?.length,
        //   itemBuilder: (context, index) {
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
    ),
        //add
        ),
    );
    //add
  }
}


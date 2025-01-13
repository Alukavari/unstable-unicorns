import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/deck.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollForDestroy extends StatefulWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  String otherID;
  int countDestroy;


  ScrollForDestroy({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.otherID,
    required this.countDestroy,
  });

  @override
  State<ScrollForDestroy> createState() => _ScrollForDestroy();

}
class _ScrollForDestroy extends State<ScrollForDestroy> {
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
    print('на скролле для уничтожения');

    if(count < widget.countDestroy) {
      switch(card.type){
        case CardClass.bonus:
          await Player.destroyBonus(card, widget.roomName, widget.otherID);
break;
        case CardClass.unicorn:
          await Player.destroyUnicorn(card, widget.roomName, widget.otherID);
break;
        case CardClass.fine:
          await Player.destroyFine(card, widget.roomName, widget.otherID);
          break;
        case CardClass.baby:
          await Player.destroyUnicorn(card, widget.roomName, widget.otherID);
break;

        default:
          print('неизвестный тип карты');
          break;
      }
      setState(() {
        destroyCards?.remove(card); // Удаляем уничтоженную карту
      });
      // if(
      // card?.type == CardClass.bonus){
      //   await Player.destroyBonus(card, widget.roomName, widget.otherID);
      //   destroyCards?.remove(card);
      //   setState(() {});
      // } else if(
      // card?.type == CardClass.unicorn){
      //   await Player.destroyUnicorn(card, widget.roomName, widget.otherID);
      //   destroyCards?.remove(card);
      //   setState(() {});
      //
      // } else if(
      // card?.type == CardClass.fine){
      //   await Player.destroyFine(card, widget.roomName, widget.otherID);
      //   destroyCards?.remove(card);
      //   setState(() {});
      // }
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
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: destroyCards?.length,
          itemBuilder: (context, index) {
            return Container(
              width: 110,
              margin: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () {
                  _onTap(context, destroyCards![index]);
                },
                onDoubleTap: () {
                  DialogWindow.show(context, destroyCards![index].description, destroyCards![index].name);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                      // widget.cards![index].imageUrl,
                      destroyCards![index].imageUrl,
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


import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/deck.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollForGame extends StatefulWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  int countDiscard;
  Function (BuildContext context, CardModel? card) onCardTap; // Функция обратного вызова для onTap


  ScrollForGame({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.countDiscard,
    required this.onCardTap,
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
    print('мы на скрол фор гейм, пытаемя уничтожить единорога');
    if(count < widget.countDiscard) {
      await widget.onCardTap!(context, card);
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
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.cards?.length,
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


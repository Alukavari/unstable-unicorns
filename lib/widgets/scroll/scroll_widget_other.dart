import 'package:flutter/material.dart';
import '../../models/card.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollWidgetOtherPlayer extends StatelessWidget {
  List<CardModel>? cards;


  ScrollWidgetOtherPlayer({
    super.key,
    required this.cards,
  });


  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards!.length,
      itemBuilder: (context, index) {
        return Container(
          width: 110,
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
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

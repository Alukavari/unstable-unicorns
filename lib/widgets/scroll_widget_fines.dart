import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/colors.dart';
import 'package:unstable_unicorns/const/const.dart';

import '../models/card.dart';
import '../services/dialog_window.dart';

class ScrollWidgetFines extends StatelessWidget {
  List<CardModel> cards;

  ScrollWidgetFines({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.white,
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

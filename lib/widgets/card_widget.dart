import 'package:flutter/material.dart';

import '../models/card.dart';
import '../services/dialog_window.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({
    super.key,
    required this.card});

  @override
  Widget build(BuildContext context) {
    print('мы тут пытаемся отобразить карту');
    return SizedBox(
      width: 110,
      height: 170,
      child: GestureDetector(
        onDoubleTap: () {
          DialogWindow.show(context, card.description, card.name);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            card.imageUrl,
            fit: BoxFit.cover,
            width: 100,
            height: 170,
          ),
        ),
      ),
    );
  }
}

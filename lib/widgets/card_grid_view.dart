import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardGridView extends StatelessWidget {

  CardGridView({required this.cards});

  final List<Image> cards;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      child: GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: cards[index],
            );
          }),
    );
  }
}



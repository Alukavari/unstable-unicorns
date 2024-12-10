import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/services/dialog_window.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game_state.dart';
import '../models/player_state.dart';

class ScrollWidgetForDeck extends StatefulWidget {
  String roomName;
  String typeDeck;
  String typeGameDeck;
  String title;
  List<CardModel>? gameDeck;
  String playerID;
  int count;

  ScrollWidgetForDeck({
    super.key,
    required this.roomName,
    required this.typeDeck,
    required this.typeGameDeck,
    required this.gameDeck,
    required this.playerID,
    required this.count,
    required this.title,
  });
  @override
  State<ScrollWidgetForDeck> createState() => _ScrollWidgetForDeckState();
  }

class _ScrollWidgetForDeckState extends State<ScrollWidgetForDeck> {
  late List<CardModel> selectedDeck;

  @override
  void initState() {
    super.initState();
    selectedDeck = [];
    for (int i = 0; i < widget.count; i++) {
      selectedDeck.add(widget.gameDeck![widget.gameDeck!.length - 1 - i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameDeck!.isEmpty || widget.gameDeck == null) {
      // return const SizedBox.shrink();
      return Center(child: Text('Empty', style: textForDialog));
    }
    if (widget.gameDeck!.length < widget.count) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogWindow.show(context,
            'Игра окончена, недостаточно карт для данного действия', 'Upps..');
      });
      return const SizedBox.shrink();
    }
    print('gameDeck count ${widget.gameDeck!.length}');
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 150, // добавили от 110
        // width: double.maxFinite, // Устанавливаем ширину для ограничений
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: selectedDeck.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onDoubleTap: () {
                DialogWindow.show(
                    context,
                    selectedDeck[index].description,
                    selectedDeck[index].name);
              },
              onTap: () {
                PlayerState.addCardsPlayerDeck(
                    widget.roomName,
                    selectedDeck[index],
                    widget.typeDeck,
                    widget.typeGameDeck,
                    widget.playerID);
                selectedDeck.removeAt(index);
                print('selectedDeck: ${selectedDeck.length}'); //добавили
                if (selectedDeck.isEmpty) {
                  Navigator.of(context).pop(); // Закрытие диалога добавили
                } else {
                  setState(() {});
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 150,
                  height: 170,
                  child: Image.asset(
                      selectedDeck[index].imageUrl,
                      fit: BoxFit.contain
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
// return ClipRRect(
    //   borderRadius: BorderRadius.circular(10),
    //   child: SizedBox(
    //     width: 110,
    //     height: 170,
    //     child: Image.asset(
    //       selectedDeck[index].imageUrl,
    //       fit: BoxFit.contain,

    // List<CardModel> selectedDeck = [];
    //
    // if (gameDeck!.isEmpty || gameDeck == null) {
    //   const Center(child: Text('empty'));
    //   return const SizedBox.shrink();
    // }
    // print('${gameDeck!.length} МАКАО');
    // print('1');
    // print('${count} КАКАО');
    // print('2');
    // print('if Макао < КАКАО');

    // if(gameDeck!.length < count) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     DialogWindow.show(
    //         context, 'Игра окончена, недостаточно карт для данного действия',
    //         'Upps..');
    //   });
    //   print('КАКАО ВИН');
    //   return const SizedBox.shrink();
    // }
    // print('А НЕ РЕТЕРНУЛО');
    //   for(int i =0; i < count; i++) {
    //     selectedDeck.add(gameDeck![gameDeck!.length - 1 - i]);
    // return AlertDialog(
    //   backgroundColor: Colors.white,
    //   title: Text('Scrollable Content'),
    //   content: SingleChildScrollView(
    //     child: ListView.builder(
    //         itemCount: gameDeck.length,
    //         itemBuilder: (context, index) {
    //           return Padding(
    //               padding: const EdgeInsets.symmetric(vertical: 8),
    //               child:
    //               Image.asset(gameDeck[index])
    //           );
    //         }
    //       //     (index) => Padding(
    //       //   padding: const EdgeInsets.symmetric(vertical: 8.0),
    //       //   child: Text('Item $index'),
    //       // ),
    //       //     ),
    //       //   ),
    //       // );
    //       // actions: [
    //       //   TextButton(
    //       //     onPressed: () => Navigator.of(context).pop(),
    //       //       child: Text('Close'),
    //       //     ),
    //       //   ],
    //     ),
    //   ),
    // );
  }
}
//   return ListView.builder(
//     shrinkWrap: true,
//     scrollDirection: Axis.horizontal,
//     itemCount: gameDeck.length,
//     itemBuilder: (context, index) {
//       return Container(
//         width: 110,
//         margin: const EdgeInsets.all(5),
//         child: Column(
//           children: [
//             gameDeck[index],
//             const SizedBox(height: 5),
//             TextButton(
//               onPressed: () {},
//               child: Center(
//                 child: Text(
//                   'add',
//                   style: textForDialog,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }




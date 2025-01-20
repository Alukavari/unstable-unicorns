import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/models/chek_possibility.dart';
import '../../const/const.dart';
import '../../const/text_for_check_dialog.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/player_state.dart';
import '../../provider/current_player_provider.dart';
import '../../provider/game_data_provider.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollWidget extends StatelessWidget {
  List<CardModel>? cards;
String myID;
String otherID;
String roomName;


  ScrollWidget({
    super.key,
    required this.cards,
    required this.myID,
    required this.otherID,
    required this.roomName,
  });

  Future<void> _handleTap(
      BuildContext context,
      CardModel newCard,
      String roomName,
      String currentPlayer,
      ) async {
    print('мы в скрол виджет actCount ${ Provider
        .of<GameDataProvider>(context, listen: false)
        .actCount}');
    bool isEven = await CheckPossibility.checkHaveUnicornForDestroy(
        context, roomName, otherID);
    bool isEvenPandec = await CheckPossibility.checkHavePandec(roomName, myID);
    bool isEvenSun = await CheckPossibility.checkHaveSun(roomName, myID);

    if (Provider
        .of<GameDataProvider>(context, listen: false)
        .actCount == 0) {
      if (!isEvenPandec || isEvenSun) {
        if (newCard.name == 'НОСОРОГОРОГ' && !isEven) {
          print(
              'не разыгрываем носрога рога из-за того что нет единорожков для угичтожения');
          await DialogWindow.show(
              context, checkText['НОСОРОГОРОГ1']!, titleForDialogWindow);
        } else {
          await Game.updatePlayOutCard(
            roomName,
            newCard,
          );
          await Player.playCard(
            context,
            roomName,
            currentPlayer,
            myID,
            otherID,
          );
        }
      }else {
        await DialogWindow.show(
            context, checkText['НОСОРОГОРОГ1']!, titleForDialogWindow);
      }
    } else{
      await DialogWindow.show(
          context, checkText['НОСОРОГОРОГ1']!, titleForDialogWindow);

    }
  }



  @override
  Widget build(BuildContext context) {
    final currentPlayer = Provider
        .of<CurrentPlayerState>(context, listen: false)
        .currentPlayer;
    final isMyTurn = currentPlayer == myID;

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards!.length,
      itemBuilder: (context, index) {
        return Container(
          width: 110,
          margin: const EdgeInsets.all(5),
          child: GestureDetector(
            onTap: isMyTurn
                ? () =>
                _handleTap(
                  context,
                  cards![index],
                  roomName,
                  currentPlayer,
                )
                : () {},
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

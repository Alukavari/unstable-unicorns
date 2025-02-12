import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/const/text_for_check_dialog.dart';
import 'package:unstable_unicorns/models/chek_possibility.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import '../../models/card.dart';
import '../../models/game.dart';
import '../../models/game_state.dart';
import '../../provider/current_player_provider.dart';
import '../../provider/game_data_provider.dart';
import '../../provider/play_out_card_provider.dart';
import '../../services/dialog/dialog_window.dart';

class ScrollWidgetBonuses extends StatelessWidget {
  List<CardModel> cards;
  String roomName;
  String myID;
  String otherID;

  ScrollWidgetBonuses({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.otherID,
  });


  Future<void> _handleTap(BuildContext context,
      CardModel newCard,
      String roomName,
      String currentPlayer,
      ) async {
    print('мы в скрол actCount ${ Provider
        .of<GameDataProvider>(context, listen: false)
        .actCount}');
    CardModel? cardPlayOut = Provider
        .of<PlayOutCardProvider>(context, listen: false)
        .playOutCard;
    bool isClever = cardPlayOut?.name == 'КЛЕВЕР-ПЕРЕВЁРТЫШ';
    List<CardModel> effects = await PlayerState.getPlayerDeck(
        roomName, 'effects', myID) ?? [];
    List<CardModel> fines = await PlayerState.getPlayerDeck(
        roomName, 'fines', myID) ?? [];

    bool isEven = effects.any((card) => card.id == newCard.id);
    print('сколько карт в эффектах в самом начале проверки${effects.length}');
    print('bool effects ${isEven}');
    bool isFines = fines.any((card) => card.name == 'ОТСТОЙЛО');

    bool isEven1 = false;
    bool isEven2 = false;
    bool isEven3 = false;


    if (newCard.name == 'ХВАТЬ-ХВАТЬ') {
      print('мы на ХВАТЬ-ХВАТЬ');
      isEven1 = await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 1);
      isEven2 = await CheckPossibility.checkHaveCardOnPD(roomName, myID, 'hand', 1);
    } else if (newCard.name == 'РАДУЖНОЕ ЛАССО') {
      print('РАДУЖНОЕ ЛАССО');
      isEven1 =
      await CheckPossibility.checkHaveCardOnPD(roomName, myID, 'hand', 3);
      isEven2 = await CheckPossibility.checkHavePandec(roomName, otherID);
      isEven3 =
      await CheckPossibility.checkHaveCardOnPD(roomName, otherID, 'stall', 1);
    } else if (newCard.name == 'АРТАБСТОЙЛО') {
      print('АРТАБСТОЙЛО');
      isEven1 =
      await CheckPossibility.checkHaveCardOnPD(roomName, myID, 'hand', 2);
      print('$isEven1');
      isEven2 = await CheckPossibility.checkHaveUnicornForDestroy(
          context, roomName, otherID);
      print('$isEven1');
      isEven3 = await CheckPossibility.checkHavePandec(roomName, otherID);
    } else if (newCard.name == 'ДИСКОБОМБА') {
      print('ДИСКОБОМБА');
      isEven1 = await CheckPossibility.checkHaveCardForSacrifice(roomName, myID);
      isEven2 = await CheckPossibility.checkHaveCardForDestroy(context, roomName, otherID, 1);
    } else if (newCard.name == 'КОФЕЙНЫЙ ДЕБОШ') {
      print('КОФЕЙНЫЙ ДЕБОШ');
      isEven1 =
      await CheckPossibility.checkHaveCardForSacrifice(roomName,myID);
      isEven2 = await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 2);
    }


    if(myID == Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer) {
      if (!isFines) {
        //0
        if (Provider
            .of<GameDataProvider>(context, listen: false)
            .actCount == 0 && !isEven) {
          if (!isClever) {
            if (newCard.name == 'ХВАТЬ-ХВАТЬ' && (!isEven1 || !isEven2)) {
              print('не могу разыграть ХВАТЬ-ХВАТЬ ');
              await DialogWindow.show(
                  context, checkText['ХВАТЬ-ХВАТЬ']!, titleForDialogWindow);
            } else
            if (newCard.name == 'АРТАБСТОЙЛО' && (!isEven1 || !isEven2 || !isEven3)) {
              print('не могу разыграть АРТАБСТОЙЛО');
              await DialogWindow.show(
                  context, checkText['АРТАБСТОЙЛО']!, titleForDialogWindow);
            } else if (newCard.name == 'РАДУЖНОЕ ЛАССО' &&
                (!isEven1 || !isEven2 || !isEven3)) {
              print('не могу разыграть РАДУЖНОЕ ЛАССО');
              await DialogWindow.show(
                  context, checkText['РАДУЖНОЕ ЛАССО']!, titleForDialogWindow);
            } else if (newCard.name == 'ДИСКОБОМБА' &&
                (!isEven1 || !isEven2)) {
              print('не могу разыграть ДИСКОБОМБА');
              await DialogWindow.show(
                  context, checkText['ДИСКОБОМБА']!, titleForDialogWindow);
            } else if (newCard.name == 'КОФЕЙНЫЙ ДЕБОШ' &&
                (!isEven1 || !isEven2)) {
              print('не могу разыграть КОФЕЙНЫЙ ДЕБОШ');
              await DialogWindow.show(
                  context, checkText['КОФЕЙНЫЙ ДЕБОШ']!, titleForDialogWindow);
            } else {
              print('сколько карт в эффектахдо добавления  ${effects.length}');

              await PlayerState.addCardPlayerDeck(
                  roomName, newCard, 'effects', myID);

              await Game.updatePlayOutCard(roomName, newCard);
              await Game.changeGameStatus('playOutBonuses', roomName);
            }
          } else {
            await DialogWindow.show(
                context, checkText['bonuses']!, titleForDialogWindow);
          }
        } else {
          await DialogWindow.show(
              context, checkText['bonuses']!, titleForDialogWindow);
        }
      } else {
        await DialogWindow.show(
            context, checkText['ОТСТОЙЛО']!, titleForDialogWindow);
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    final currentPlayer = Provider.of<CurrentPlayerState>(context).currentPlayer;
    final isMyTurn = currentPlayer == myID;

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return Container(
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
                  context, cards[index].description, cards[index].name);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                // color: Colors.white,
                color: Colors.orangeAccent,
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

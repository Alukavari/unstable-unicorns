import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/const/text_for_check_dialog.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import '../../models/card.dart';
import '../../models/chek_possibility.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../provider/current_player_provider.dart';
import '../../services/dialog/dialog_window.dart';
import '../../provider/play_out_card_provider.dart';
import '../../provider/game_data_provider.dart';

class ScrollHandCard extends StatelessWidget {
  List<CardModel>? cards;
  String roomName;
  String myID;
  String otherID;

  ScrollHandCard({
    super.key,
    required this.cards,
    required this.roomName,
    required this.myID,
    required this.otherID,
  });

  Future<void> _handleTap(
      BuildContext context,
      CardModel newCard,
      String roomName,
      String currentPlayer,) async {
    print('мы в скрол actCount ${ Provider.of<GameDataProvider>(context, listen: false).actCount}');

    List<CardModel> deckCard = await GameState.getDeck(roomName, 'deck');
    List<CardModel> fines = await PlayerState.getPlayerDeck(roomName, 'fines', myID) ?? [];
 bool isEvenPandec = await CheckPossibility.checkHavePandec(roomName, myID);
 bool isEvenSun = await CheckPossibility.checkHaveSun(roomName, myID);

 int countDeck = deckCard.length ?? 0;
    bool isEven = false;
    bool isEven1 = false;
    bool isEven2 = false;
    bool isEven3 = false;

    if (countDeck == 0) {
      await Game.checkVictoryConditions(roomName, currentPlayer);
    }

    if(myID == Provider.of<CurrentPlayerState>(context, listen:false).currentPlayer ){
      print('статус карты в скролл хэнд ${newCard.type}');
      //бонус
      if(newCard.type == CardClass.spell) {
        if (newCard.name == 'ЕДИНОРОЖИЙ ЯД') {
          isEven = await CheckPossibility.checkHaveUnicornForDestroy(
              context, roomName, otherID);
          isEven1 = await CheckPossibility.checkCat(roomName, otherID);
        } else if (newCard.name == 'ДВА ПО ЦЕНЕ ОДНОГО') {
          isEven =
          await CheckPossibility.checkHaveCardForSacrifice(roomName, myID);
          isEven1 = await CheckPossibility.checkHaveCardForDestroy(
              context, roomName, otherID, 2);
        } else if (newCard.name == 'ЦЕЛЬСЬ!') {
          isEven =
          await CheckPossibility.checkHaveFinesOrBonuses(
              roomName, myID, otherID);
        } else if (newCard.name == 'НАГЛЫЙ ГРАБЕЖ') {
          isEven = await CheckPossibility.checkHaveCardOnPD(
              roomName, otherID, 'hand', 1);
        } else if (newCard.name == 'ПРИЦЕЛЬНАЯ АТАКА') {
          print('ПРИЦЕЛЬНАЯ АТАКА');
          isEven =
          await CheckPossibility.checkHaveFinesOrBonuses(
              roomName, myID, otherID);
        } else if (newCard.name == 'ЧИСТАЯ ВЫГОДА') {
          isEven =
          await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 3);
        } else if (newCard.name == 'ВСТРЯСКА') {
          isEven =
          await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 5);
        } else if (newCard.name == 'ПЕРЕЗАГРУЗКА') {
          isEven =
          await CheckPossibility.checkHaveFinesOrBonuses(
              roomName, myID, otherID);
        } else if (newCard.name == 'БЛЕСТЯЩЕЕ ТОРНАДО') {
          isEven =
          await CheckPossibility.checkHaveCardOnStall(roomName, myID, otherID);
        } else if (newCard.name == 'КЛЕВЕР-ПЕРЕВЁРТЫШ') {
          isEven =
          await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 2);
        }else if (newCard.name == 'ПИНОК') {
          isEven =
          await CheckPossibility.checkHaveCardOnPD(roomName, otherID, 'stall', 1);
        } else if (newCard.name == 'ОБМЕН ЕДИНОРОЖКАМИ') {
          isEven = await CheckPossibility.checkHaveCardOnPD(roomName, otherID, 'stall', 1);
          isEven1 = await CheckPossibility.checkHaveCardOnPD(roomName, myID, 'stall', 1);
          isEven2 = await CheckPossibility.checkHavePandec(roomName, myID);
          isEven3 = await CheckPossibility.checkHavePandec(roomName, otherID);
        }
      }

      if(newCard.type == CardClass.unicorn) {
        if (!isEvenPandec && !isEvenSun) {
          if (newCard.name == 'ПОЧАТОК РОГ') {
            print('ПОЧАТОК РОГ');
            isEven =
            await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 2);
            print('$isEven');
          } else if (newCard.name == 'ТЕМНЫЙ АНГЕЛОРОГ') {
            print('ТЕМНЫЙ АНГЕЛОРОГ');
            isEven = await CheckPossibility.checkHaveUnicornForSacrifice(
                context, roomName, myID);
          } else if (newCard.name == 'ОРАКУЛОРОГ') {
            print('ОРАКУЛОРОГ');
            isEven =
            await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 3);
          } else if (newCard.name == 'АМЕРИРОГ') {
            print('АМЕРИРОГ');
            isEven = await CheckPossibility.checkHaveCardOnPD(
                roomName, otherID, 'hand', 1);
          } else if (newCard.name == 'ЖАДНЫЙ КРЫЛОРОГ') {
            print('ЖАДНЫЙ КРЫЛОРОГ');
            isEven =
            await CheckPossibility.checkHaveCardOnDeck(roomName, 'deck', 1);
          }
        }
      }

      //0
      if (Provider
              .of<GameDataProvider>(context, listen: false)
              .actCount == 0) {
        DialogWindow.show(context, 'Take a card from the deck', 'Notification');
          //1
      }else if (
          Provider
              .of<GameDataProvider>(context, listen: false)
              .actCount == 1) {
        if (newCard.type == CardClass.tpru) {
          DialogWindow.show(
              context, 'You can\'t play TPRU, choose another card',
              'Notification');
          //spell
        }
        else if (newCard.type == CardClass.spell) {

           if (newCard.name == 'ЕДИНОРОЖИЙ ЯД' && (!isEven|| !isEven1)) {
            print('ne mogu sigrat edinirizi ayd');
            DialogWindow.show(context,
                    checkText[newCard.name]!,
                'Notification');

        }else if (newCard.name == 'ДВА ПО ЦЕНЕ ОДНОГО' && (!isEven || !isEven1)) {
          print('$isEven');
          print('$isEven1');
            print('не могу сыгырать два по цене одного');
            DialogWindow.show(context,
                checkText[newCard.name]!,
                'Notification');
          } else if (newCard.name == 'ЦЕЛЬСЬ!' && !isEven) {
            print('не могу сыгырать цельс');
            DialogWindow.show(context,
                checkText[newCard.name]!,
                'Notification');
        }else if(newCard.name == 'НАГЛЫЙ ГРАБЕЖ' && !isEven){
          print('НАГЛЫЙ ГРАБЕЖ');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }else if(newCard.name == 'ПРИЦЕЛЬНАЯ АТАКА' && !isEven){
          print('ПРИЦЕЛЬНАЯ АТАКА');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }
        else if(newCard.name == 'ЧИСТАЯ ВЫГОДА' && !isEven){
          print('ЧИСТАЯ ВЫГОДА');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }else if(newCard.name == 'ВСТРЯСКА' && !isEven){
          print('ВСТРЯСКА');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        } else if(newCard.name == 'БЛЕСТЯЩЕЕ ТОРНАДО' && !isEven){
          print('БЛЕСТЯЩЕЕ ТОРНАДО');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }else if(newCard.name == 'ПЕРЕЗАГРУЗКА' && !isEven){
          print('ПЕРЕЗАГРУЗКА');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }else if(newCard.name == 'КЛЕВЕР-ПЕРЕВЁРТЫШ' && !isEven){
          print('КЛЕВЕР-ПЕРЕВЁРТЫШ');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }else if(newCard.name == 'ПИНОК' && !isEven){
          print('ПИНОК');
          DialogWindow.show(context,
              checkText[newCard.name]!,
              'Notification');
        }else if(newCard.name == 'ОБМЕН ЕДИНОРОЖКАМИ' && (!isEven || !isEven1 || !isEven2 || !isEven3)) {
             print(' nelza ОБМЕН ЕДИНОРОЖКАМИ');
             print(isEven);
             print(isEven1);
             print(isEven2);
             print(isEven3);
             DialogWindow.show(context,
                 checkText[newCard.name]!,
                 'Notification');
           }else {
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
             await Game.incrementActCount(roomName);

           }
        }
        else if(newCard.type == CardClass.unicorn) {
          if (!isEvenPandec && !isEvenSun) {
            if (newCard.name == 'ПОЧАТОК РОГ' && !isEven) {
              print('ne mogu ПОЧАТОК РОГ');
              DialogWindow.show(context,
                  checkText[newCard.name]!,
                  'Notification');
            } else if (newCard.name == 'ТЕМНЫЙ АНГЕЛОРОГ' && !isEven) {
              print('ne mogu ТЕМНЫЙ АНГЕЛОРОГ');
              DialogWindow.show(context,
                  checkText[newCard.name]!,
                  'Notification');
            } else if (newCard.name == 'ОРАКУЛОРОГ' && !isEven) {
              print('ne mogu ОРАКУЛОРОГ');
              DialogWindow.show(context,
                  checkText[newCard.name]!,
                  'Notification');
            } else if (newCard.name == 'АМЕРИРОГ' && !isEven) {
              print('ne mogu АМЕРИРОГ');
              DialogWindow.show(context,
                  checkText[newCard.name]!,
                  'Notification');
            } else if (newCard.name == 'ЖАДНЫЙ КРЫЛОРОГ' && !isEven) {
              print('ne mogu ЖАДНЫЙ КРЫЛОРОГ');
              DialogWindow.show(context,
                  checkText[newCard.name]!,
                  'Notification');
            } else if (newCard.name == 'НОСОРОГОРОГ' && !isEven) {
              print('ne mogu ЖАДНЫЙ КРЫЛОРОГ');
              DialogWindow.show(context,
                  checkText[newCard.name]!,
                  'Notification');
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
              await Game.incrementActCount(roomName);
            }
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
            await Game.incrementActCount(roomName);
          }
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
          await Game.incrementActCount(roomName);
        }
      //2
      }else if (Provider
          .of<GameDataProvider>(context, listen: false)
          .actCount == 2 ) {
        DialogWindow.show(
            context, 'You have finished change your turn', 'Notification');
        //3
      } else if (Provider.of<GameDataProvider>(context, listen: false).actCount >= 3
      ) {
        if (Provider
            .of<DiscardCardProvider>(context, listen: false)
            .discardCard !=
            0) {
          await GameState.updateWithNewCardGameDeck(
              roomName, newCard, 'discardPile');
          await PlayerState.removeCardFromPlayerDeck(
              roomName, newCard, 'hand', currentPlayer);
          Provider.of<DiscardCardProvider>(context, listen: false)
              .decreaseDiscardCard();
        }
      }
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

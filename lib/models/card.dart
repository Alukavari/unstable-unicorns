import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/narwhal_unicorns.dart';
import 'package:unstable_unicorns/models/chek_possibility.dart';
import 'package:unstable_unicorns/models/game_state.dart';
import 'package:unstable_unicorns/models/player.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';
import 'package:unstable_unicorns/services/dialog/dialog_for_game.dart';
import 'package:unstable_unicorns/services/dialog/dialog_for_game_choose.dart';
import 'package:unstable_unicorns/services/dialog/dialog_for_no.dart';
import 'package:unstable_unicorns/services/dialog/dialog_window.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_destroy.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_game.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_moving_card.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_multy_discard.dart';
import 'package:unstable_unicorns/widgets/scroll/scroll_for_sacrifice.dart';
import '../const/const.dart';
import '../const/deckOfCards.dart';
import '../const/text_for_check_dialog.dart';
import 'game.dart';

enum CardClass {
  bonus,
  unicorn,
  spell,
  fine,
  tpru,
  baby,
}

class CardModel {
  late final String name;
  final String description;
  final CardClass type;
  final String imageUrl;
  final String id;

  CardModel(this.name,
      this.description,
      this.type,
      this.imageUrl,
      this.id,);

  // Метод для преобразования карточки в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type
          .toString()
          .split('.')
          .last,
      'imageUrl': imageUrl,
      'id': id,
    };
  }

  // Метод для создания карточки из Map
  static CardModel fromMap(Map<String, dynamic> map) {
    return CardModel(
      map['name'] as String,
      map['description'] as String,
      CardClass.values
          .firstWhere((e) =>
      e
          .toString()
          .split('.')
          .last == map['type']),
      map['imageUrl'] as String,
      map['id'] as String,
    );
  }

// заклинание два по цене одного
  static Future<void> spellTwoForThePriceOfOne(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы в два по цене одного');

    List<CardModel> allMyCard = [];
    List<CardModel>? myStall =
    await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    if (myStall!.isNotEmpty) {
      allMyCard.addAll(myStall);
    }
    List<CardModel>? myBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    if (myBonus!.isNotEmpty) {
      allMyCard.addAll(myBonus);
    }
    List<CardModel>? myFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    if (myFines!.isNotEmpty) {
      allMyCard.addAll(myFines);
    }
    //проверяем есть ли бонус радужная аура
    List<CardModel> allOtherCard = [];
    bool isEven =
    await CheckPossibility.checkRainbowAura(roomName, otherID, context);
    if (!isEven) {
      List<CardModel>? otherStall =
      await PlayerState.getPlayerDeck(roomName, 'stall', otherID);
      if (otherStall!.isNotEmpty) {
        allOtherCard.addAll(otherStall);
      }
    }

    List<CardModel>? otherBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
    if (otherBonus!.isNotEmpty) {
      allOtherCard.addAll(otherBonus);
    }
    List<CardModel>? otherFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', otherID);
    if (otherFines!.isNotEmpty) {
      allOtherCard.addAll(otherFines);
    }

      await DialogForGame.show(
          context,
          cardDescription['ДВА ПО ЦЕНЕ ОДНОГО1']!,
          roomName,
          allMyCard,
          myID,
          otherID,
          ScrollForSacrifice(
              cards: allMyCard,
              roomName: roomName,
              myID: myID,
              countDiscard: 1));

      await DialogForGame.show(
        context,
        cardDescription['ДВА ПО ЦЕНЕ ОДНОГО2']!,
        roomName,
        allOtherCard,
        myID,
        otherID,
        ScrollForDestroy(
            cards: allOtherCard,
            roomName: roomName,
            myID: myID,
            otherID: otherID,
            countDestroy: 2),
      );
  }


//заклинания единорожий яд
  static Future<void> spellUnicornPoison(String roomName,
      String myID,
      String otherID,
      CardModel? card,
      BuildContext context,) async {
//текущий игрок
    print('мы на розыгрыше единорожьего яда');

    String description = cardDescription['ЕДИНОРОЖИЙ ЯД'] ?? '';

    List<CardModel>? deck =
    await PlayerState.getPlayerDeck(roomName, 'stall', otherID);
    bool containsCatUnicorn =
        deck?.any((card) => card.name == 'ВОЛШЕБНЫЙ КОТОРОГ') ?? false;
    print('есть ли у нас которог $containsCatUnicorn');
    if (containsCatUnicorn) {
      CardModel? card =
      deck?.firstWhere((card) => card.name == 'ВОЛШЕБНЫЙ КОТОРОГ');
      deck?.remove(card);

      await DialogForGame.show(
        context,
        description,
        roomName,
        deck,
        myID,
        otherID,
        ScrollForGame(
          cards: deck,
          roomName: roomName,
          myID: myID,
          countDiscard: 1,
          onCardTap: (BuildContext context, CardModel? card) async {
            await Player.destroyUnicorn(card, roomName, otherID);
          },
        ),
      );
    } else {
      await DialogForGame.show(
        context,
        description,
        roomName,
        deck,
        myID,
        otherID,
        ScrollForGame(
          cards: deck,
          roomName: roomName,
          myID: myID,
          countDiscard: 1,
          onCardTap: (BuildContext context, CardModel? card) async {
            await Player.destroyUnicorn(card, roomName, otherID);
          },
        ),
      );
    }
  }

  static Future<void> spellTarget(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше цельсь');
    String description = cardDescription['ЦЕЛЬСЬ!'] ?? '';

    List<CardModel>? myCard = [];
    List<CardModel>? otherCard = [];


    List<CardModel>? myBonuses = await PlayerState.getPlayerDeck(
        roomName, 'bonuses', myID);
    print('сколько bonuses my $myBonuses');
    if (myBonuses != null) {
      myCard.addAll(myBonuses);
    }

    List<CardModel>? myFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    print('сколько  my fines $myFines');

    if (myFines != null) {
      myCard.addAll(myFines);
    }

    print('сколько myCard $myCard');


    List<CardModel>? otherBonuses = await PlayerState.getPlayerDeck(
        roomName, 'bonuses', otherID);
    print('сколько  other fines $otherBonuses');

    if (otherBonuses != null) {
      otherCard.addAll(otherBonuses);
    }

    List<CardModel>? otherFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', otherID);
    print('сколько  other bonuses $otherFines');

    if (otherFines != null) {
      otherCard.addAll(otherFines);
    }

    print('сколько otherCard $otherCard');



    await DialogForGameChoose.show(
        context,
        description,
        myID,
        otherID,
        roomName,
        'give card',
        'take card',
        ScrollForGame(cards: myCard,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (context, CardModel? card) async {
              await Player.changeCardFromPlayerDeck(
                  card!, roomName, myID, otherID);
            }),
        ScrollForGame(cards: otherCard,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (context, CardModel? card) async {
              await Player.changeCardFromPlayerDeck(
                  card!, roomName, otherID, myID);
            }));
  }

  static Future<void> spellSteal(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше НАГЛЫЙ ГРАБЕЖ');

    String description = cardDescription['НАГЛЫЙ ГРАБЕЖ'] ?? '';

    List<CardModel>? deck =
    await PlayerState.getPlayerDeck(roomName, 'hand', otherID);
    await DialogForGame.show(
        context,
        description,
        roomName,
        deck,
        myID,
        otherID,
        ScrollForGame(
            cards: deck,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (BuildContext context, CardModel? card) async {
              await Player.moveCardFromPDToPD(
                  card!, roomName, 'hand', 'hand', otherID, myID);
            }));
  }

  static Future<void> spellAttack(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше ПРИЦЕЛЬНАЯ АТАКА');

    String description = cardDescription['ПРИЦЕЛЬНАЯ АТАКА'] ?? '';

    List<CardModel>? deck = [];
    List<CardModel>? deckBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
    if (deckBonus != null) {
      deck.addAll(deckBonus);
    }
    List<CardModel>? deckFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);

    if (deckFines != null) {
      deck.addAll(deckFines);
    }
    if (deck.isNotEmpty) {
      await DialogForGame.show(
          context,
          description,
          roomName,
          deck,
          myID,
          otherID,
          ScrollForGame(
              cards: deck,
              roomName: roomName,
              myID: myID,
              countDiscard: 1,
              onCardTap: (BuildContext context, CardModel? card) async {
                await Player.destroyBonusOrFine(card, roomName, otherID, myID);
              }));
    }
  }

  // карта чистая выгода
  static Future<void> spellBenefit(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше карты ЧИСТАЯ ВЫГОДА спеллбенифит');
    List<CardModel> takeCard = await GameState.getDeck(roomName, 'deck');
    String? description = cardDescription['ЧИСТАЯ ВЫГОДА'];


    for (int i = 0; i < 3; i++) {
      CardModel card = takeCard[takeCard.length - 1 - i];
      await Player.moveCardFromGDToPD(card, roomName, 'deck', 'hand', myID);
    }

    List<CardModel>? deck =
    await PlayerState.getPlayerDeck(roomName, 'hand', myID);

    await DialogForGame.show(
        context,
        description!,
        roomName,
        deck,
        myID,
        otherID,
        ScrollForGame(
            cards: deck,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (BuildContext context, CardModel? card) async {
              await Player.cardDiscard(context, roomName, card!, myID);
            }));
  }

  static Future<void> spellShake(String roomName,
      String myID,) async {
    print('мы на розыгрыше карты ВСТРЯСКА');

// сколько карт в руке
    List<CardModel>? handCard = [];

    handCard = await PlayerState.getPlayerDeck(roomName, 'hand', myID) ?? [];
    print('сколько карт в руке было ${handCard.length}');

    //сколько карт в колоде
    List<CardModel> deck = [];
    deck = await GameState.getDeck(roomName, 'deck');
    print('сколько карт в колоде до добавления карт из рук${deck.length}');

//добавили в колоду карты с рук
    await GameState.addNewGameDeck(roomName, handCard, 'deck');
    deck = await GameState.getDeck(roomName, 'deck');
    print('сколько карт в колоде после добавления карт из рук${deck.length}');

    await PlayerState.updatePlayerDeck(roomName, [], 'hand', myID);
    handCard = await PlayerState.getPlayerDeck(roomName, 'hand', myID) ?? [];
    print('сколько карт в руке после удаления ${handCard.length}');

//сколько карт в сбрсое
    List<CardModel> discardPileCard = [];
    discardPileCard = await GameState.getDeck(roomName, 'discardPile') ?? [];
    print('сколько было в сбросе ${discardPileCard.length}');
    //добавили карты из сброса в колоду
    await GameState.addNewGameDeck(roomName, discardPileCard, 'deck');
    deck = await GameState.getDeck(roomName, 'deck');
    print(
        'сколько карт в колоде до добавления карт еще и из сброса${deck
            .length}');
// обнулили карты в сбросе
    await GameState.updateDeck(roomName, [], 'discardPile');
    discardPileCard = await GameState.getDeck(roomName, 'discardPile') ?? [];
    print('сколько было в сбросе после удаления ${discardPileCard.length}');

    deck = await GameState.getDeck(roomName, 'deck');
    CardModel? card = await Game.getPlayOutCard(roomName);
    if (card != null) {
      deck.add(card);
    }
    deck.shuffle();
    await GameState.updateDeck(roomName, deck, 'deck');

    for (int i = 0; i < 5; i++) {
      CardModel card = deck[i];
      await PlayerState.addCardPlayerDeck(roomName, card, 'hand', myID);
      await GameState.removeCardGameDeck(roomName, card, 'deck');
    }

    handCard = await PlayerState.getPlayerDeck(roomName, 'hand', myID);
    print(
        'сколько карт в руке после всех манипуляций с колодами ${handCard!
            .length}');
  }

  static Future<void> spellReboot(String roomName,
      String myID,
      String otherID,) async {
    List<CardModel> myBonus = [];
    List<CardModel> otherBonus = [];
    List<CardModel> otherFines = [];
    List<CardModel> myFines = [];
    List<CardModel> discardPile = [];
    List<CardModel> shake = [];
    List<CardModel> deck = [];

    myBonus = await PlayerState.getPlayerDeck(roomName, 'bonuses', myID) ?? [];
    shake.addAll(myBonus);

    myFines = await PlayerState.getPlayerDeck(roomName, 'fines', myID) ?? [];
    shake.addAll(myFines);

    otherBonus =
        await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID) ?? [];
    shake.addAll(otherBonus);

    otherFines =
        await PlayerState.getPlayerDeck(roomName, 'fines', otherID) ?? [];
    shake.addAll(otherFines);

    discardPile = await GameState.getDeck(roomName, 'discardPile');
    shake.addAll(discardPile);


    deck = await GameState.getDeck(roomName, 'deck');
    CardModel? card = await Game.getPlayOutCard(roomName);
    if (card != null) {
      deck.add(card);
    }
    shake.addAll(deck);

    print('сколько в итоге карт у нас поулчилось ${shake.length}');
    shake.shuffle();
    await GameState.updateDeck(roomName, shake, 'deck');

    await PlayerState.updatePlayerDeck(roomName, [], 'bonuses', myID);
    await PlayerState.updatePlayerDeck(roomName, [], 'bonuses', otherID);
    await PlayerState.updatePlayerDeck(roomName, [], 'fines', otherID);
    await PlayerState.updatePlayerDeck(roomName, [], 'fines', myID);
  }


  static Future<void> spellTornado(BuildContext, context,
      String roomName,
      String myID,
      String otherID,) async {
    List<CardModel>? myStall = await Player.takeAllCardOnStall(roomName, myID);
    List<CardModel>? otherStall = await Player.takeAllCardOnStall(
        roomName, otherID);

    await DialogForGame.show(
        context,
        cardDescription['БЛЕСТЯЩЕЕ ТОРНАДО1']!,
        roomName,
        myStall,
        myID,
        otherID,
        ScrollForGame(
            cards: myStall,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (context, CardModel? card) async {
              await Player.takeCardOnHand(card!, roomName, myID);
            }));

    await DialogForGame.show(
        context,
        cardDescription['БЛЕСТЯЩЕЕ ТОРНАДО2']!,
        roomName,
        otherStall,
        myID,
        otherID,
        ScrollForGame(
            cards: otherStall,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (context, CardModel? card) async {
              await Player.takeCardOnHand(card!, roomName, otherID);
            }));
  }

  static Future<void> spellTurningClover(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше карты перевертыщ');

    String? description = cardDescription['КЛЕВЕР-ПЕРЕВЕРТЫШ'];

    List<CardModel> takeCard = await GameState.getDeck(roomName, 'deck');
    for (int i = 0; i < 2; i++) {
      CardModel card = takeCard[takeCard.length - 1 - i];
      await Player.moveCardFromGDToPD(card, roomName, 'deck', 'hand', myID);
    }

    List<CardModel>? deck =
    await PlayerState.getPlayerDeck(roomName, 'hand', myID);

    await DialogForGame.show(
      context,
      description!,
      roomName,
      deck,
      myID,
      otherID,
      ScrollForMultiDiscard(
          cards: deck,
          roomName: roomName,
          myID: myID,
          countDestroy: 3),
    );

    await Game.decreaseActCount(roomName);
    await Game.decreaseActCount(roomName);
    print('минус ход ${Provider
        .of<GameDataProvider>(context, listen: false)
        .actCount}');
  }


  static Future<void> spellExchangeUnicorn(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше картs обмен единорожками');

    String? description = cardDescription['ОБМЕН ЕДИНОРОЖКАМИ'];
    String? description2 = cardDescription['ОБМЕН ЕДИНОРОЖКАМИ1'];

    List<CardModel>? myStall = await PlayerState.getPlayerDeck(
        roomName, 'stall', myID);
    List<CardModel>? otherStall = await PlayerState.getPlayerDeck(
        roomName, 'stall', otherID);


    await DialogForGame.show(
        context,
        description!,
        roomName,
        myStall,
        myID,
        otherID,
        ScrollForGame(
            cards: myStall,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (BuildContext context, CardModel? card) async {
              await Player.moveCardFromPDToPD(
                  card!, roomName, 'stall', 'stall', myID, otherID);
            }));

    await DialogForGame.show(
        context,
        description2!,
        roomName,
        otherStall,
        myID,
        otherID,
        ScrollForGame(
            cards: otherStall,
            roomName: roomName,
            myID: myID,
            countDiscard: 1,
            onCardTap: (BuildContext context, CardModel? card) async {
              await Player.moveCardFromPDToPD(
                  card!, roomName, 'stall', 'stall', otherID, myID);
            }));
  }


  static Future<void> spellKissOfLove(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше карт kiss of love');

    String? description = cardDescription['ПОЦЕЛУЙ ЛЮБВИ'];

    List<CardModel>? deck = await Player.takeSpecificCardsFromGDTOPD(
        CardClass.unicorn, roomName, 'discardPile');

    if (deck!.isNotEmpty) {
      await DialogForGame.show(
          context,
          description!,
          roomName,
          deck,
          myID,
          otherID,
          ScrollForGame(
              cards: deck,
              roomName: roomName,
              myID: myID,
              countDiscard: 1,
              onCardTap: (BuildContext context, CardModel? card) async {
                await Player.moveCardFromGDToPD(
                    card!, roomName, 'discardPile', 'stall', myID);
              }));
    } else {
      await DialogWindow.show(
          context, checkText['ПОЦЕЛУЙ ЛЮБВИ']!, titleForDialogWindow);
    }
  }

  static Future<void> spellRawDeal(String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше карт НЕЧЕСТНАЯ СДЕЛКА');


    List<CardModel>? myHand = await PlayerState.getPlayerDeck(
        roomName, 'hand', myID);
    List<CardModel>? otherHand = await PlayerState.getPlayerDeck(
        roomName, 'hand', otherID);

    await PlayerState.updatePlayerDeck(roomName, otherHand!, 'hand', myID);
    await PlayerState.updatePlayerDeck(roomName, myHand!, 'hand', otherID);
  }

  static Future<void> spellMysticalWhirlpool(BuildContext context,
      String roomName,
      String myID,
      String otherID,) async {
    print('мы на розыгрыше карт МИСТИЧЕСКИЙ ВОДОВОРОТ');

    List<CardModel>? deck = await PlayerState.getPlayerDeck(
        roomName, 'hand', myID);

    if (deck!.isNotEmpty) {
      await DialogForGame.show(
          context,
          cardDescription['МИСТИЧЕСКИЙ ВОДОВОРОТ']!,
          roomName,
          deck,
          myID,
          otherID,
          ScrollForGame(cards: deck,
              roomName: roomName,
              myID: myID,
              countDiscard: 1,
              onCardTap: (context, CardModel? card) async {
                await Player.cardDiscard(context, roomName, card!, myID);
              }));

      List<CardModel>? discardPile = await GameState.getDeck(
          roomName, 'discardPile');
      List<CardModel>? gameDeck = await GameState.getDeck(roomName, 'deck');
      discardPile.addAll(gameDeck);
      discardPile.shuffle();

      await GameState.updateDeck(roomName, discardPile, 'deck');
      await GameState.updateDeck(roomName, [], 'discardPile');
    }
  }

  static Future<void> spellKick(BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async {
    print('мы на розыгрыше карт ПИНОК');
    List<CardModel> allMyCard = [];
    List<CardModel>? myStall =
    await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    if (myStall!.isNotEmpty) {
      allMyCard.addAll(myStall);
    }
    List<CardModel>? myBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    if (myBonus!.isNotEmpty) {
      allMyCard.addAll(myBonus);
    }
    List<CardModel>? myFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    if (myFines!.isNotEmpty) {
      allMyCard.addAll(myFines);
    }

    if (allMyCard!.isNotEmpty) {
      await DialogForGame.show(
          context,
          cardDescription['ПИНОК']!,
          roomName,
          allMyCard,
          myID,
          otherID,
          ScrollForGame(cards: allMyCard,
              roomName: roomName,
              myID: myID,
              countDiscard: 1,
              onCardTap: (context, CardModel? card) async {
                await Player.takeCardOnHand(card!, roomName, myID);
              }));

      List<CardModel>? deck = await PlayerState.getPlayerDeck(roomName, 'hand', myID);
      await DialogForGame.show(
          context,
          cardDescription['ПИНОК1']!,
          roomName,
          deck,
          myID,
          otherID,
          ScrollForGame(cards: deck,
              roomName: roomName,
              myID: myID,
              countDiscard: 1,
              onCardTap: (context, CardModel? card) async {
                await Player.cardDiscard(context, roomName, card!, myID);
              }));

    }
  }

  static Future<void> playOutSpellForNoCurrentPlayer(BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,) async{
    await Game.changeGameStatus('inProcess', roomName);
    if(card?.name == 'МИСТИЧЕСКИЙ ВОДОВОРОТ'){
      print('разыгрываем МИСТИЧЕСКИЙ ВОДОВОРОТ для не текущего игрока');
      await CardModel.spellMysticalWhirlpool(context, roomName, myID, otherID);
    } else if(card?.name == 'МИСТИЧЕСКИЙ ВОДОВОРОТ'){
      print('разыгрываем МИСТИЧЕСКИЙ ВОДОВОРОТ для не текущего игрока');
      await CardModel.spellMysticalWhirlpool(context, roomName, myID, otherID);
    }else if(card?.name == 'ПИНОК'){
      print('разыгрываем ПИНОК1 для не текущего игрока');
      await CardModel.spellKick(context, roomName, myID, otherID);
    }
  }


// заклинания
  static Future<void> playOutSpell(BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,) async {
    CardModel? card = await Game.getPlayOutCard(roomName);
    print('разыгырваемая карта в плэйспелл ${card?.name}');

CardModel? jump;
    List<CardModel>? bonuses = await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    List<CardModel>? fines = await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    List<CardModel>? effects = await PlayerState.getPlayerDeck(roomName, 'effects', myID);
    bool isEven = fines?.any((card)=> card.name =='ОТСТОЙЛО') ?? false;

    bool isEvenJump = bonuses?.any((card)=> card.name =='ПРЫГ-СКОК') ?? false;
    print('есть ли карта ПРЫГ-СКОК $isEvenJump ');
    bool isEvenEffects = effects?.any((card)=> card.name =='ПРЫГ-СКОК') ?? false;
    print('есть ли карта in effects $isEvenEffects ');

    if(isEvenJump && !isEven){
      jump = effects?.firstWhere((card)=> card.name =='ПРЫГ-СКОК');
      print('jump ${jump!.name} ');

    }

    if (card?.name == 'ЕДИНОРОЖИЙ ЯД') {
        print('мы на розыгрыше заклинания единорожий яд');
        await spellUnicornPoison(
          roomName,
          myID,
          otherID,
          card!,
          context,
        );
      }
      else if (card?.name == 'ДВА ПО ЦЕНЕ ОДНОГО') {
        print('на условии что это заклинанеи два поцене одного');
        await spellTwoForThePriceOfOne(context, roomName, myID, otherID);
      }
      else if (card?.name == 'ЦЕЛЬСЬ!') {
        print('мы на условииЮ что это цельсь');
        await spellTarget(context, roomName, myID, otherID);
      }
      else if (card?.name == 'НАГЛЫЙ ГРАБЕЖ') {
        print('мы на условииЮ что это грабеж');

        await spellSteal(context, roomName, myID, otherID);
      }
      else if (card?.name == 'ПРИЦЕЛЬНАЯ АТАКА') {
        print('мы на условии что это ПРИЦЕЛЬНАЯ АТАКА');
        await spellAttack(context, roomName, myID, otherID);
      }
      else if (card?.name == 'ЧИСТАЯ ВЫГОДА') {
        print('мы на условии что это ЧИСТАЯ ВЫГОДА');
        await spellBenefit(context, roomName, myID, otherID);
      }
      else if (card?.name == 'ВСТРЯСКА') {
        print('мы на условии что это ВСТРЯСКА');
        await spellShake(roomName, myID);
      }
      else if (card?.name == 'ПЕРЕЗАГРУЗКА') {
        print('мы на условии что это ПЕРЕЗАГРУЗКА');
        await spellReboot(roomName, myID, otherID);
      }
      else if (card?.name == 'БЛЕСТЯЩЕЕ ТОРНАДО') {
        print('мы на условии что это БЛЕСТЯЩЕЕ ТОРНАДО');
        await spellTornado(BuildContext, context, roomName, myID, otherID);
      }
      else if (card?.name == 'КЛЕВЕР-ПЕРЕВЁРТЫШ') {
        print('мы на условии что это КЛЕВЕР-ПЕРЕВЁРТЫШ');
        await spellTurningClover(context, roomName, myID, otherID);
      }
      else if (card?.name == 'ОБМЕН ЕДИНОРОЖКАМИ') {
        print('мы на условии что это ОБМЕН ЕДИНОРОЖКАМИ');
        await spellExchangeUnicorn(context, roomName, myID, otherID);
      }
      else if (card?.name == 'ПОЦЕЛУЙ ЛЮБВИ') {
        print('мы на условии что это ПОЦЕЛУЙ ЛЮБВИ');
        await spellKissOfLove(context, roomName, myID, otherID);
      }
      else if (card?.name == 'НЕЧЕСТНАЯ СДЕЛКА') {
        print('мы на условии что это ОНЕЧЕСТНАЯ СДЕЛКА');
        await spellRawDeal(roomName, myID, otherID);
      } else if (card?.name == 'МИСТИЧЕСКИЙ ВОДОВОРОТ') {
        print('мы на условии что это МИСТИЧЕСКИЙ ВОДОВОРОТ');
        await spellMysticalWhirlpool(context, roomName, myID, otherID);
      }


    await Game.changeGameStatus('inProcess', roomName);

    if (card?.name != 'ПЕРЕЗАГРУЗКА' && card?.name != 'ВСТРЯСКА' &&
        card?.name != 'МИСТИЧЕСКИЙ ВОДОВОРОТ') {
      await GameState.updateWithNewCardGameDeck(
          roomName, card!, 'discardPile');
    } else {
      await Player.shuffleDeckWithNewCard(roomName, card, 'deck');
      await GameState.updateDeck(roomName, [], 'discardPile');
    }
    await GameState.removeCardGameDeck(
      roomName,
      card!,
      'playingCardOnTable',
    );

    if( isEven || !isEvenJump || isEvenEffects) {
      print('нет прыг-скок или он не повторяется');
      await Game.checkCountCardOnHand(
        context,
        roomName,
        'hand',
        Provider
            .of<CurrentPlayerState>(context, listen: false)
            .currentPlayer,
        myID,
        otherID,
      );
    } else{
      print('есть прыг-скок или  2 хода');

      await Game.decreaseActCount(roomName);
      await PlayerState.addCardPlayerDeck(roomName, jump!, 'effects', myID);
    }
    await PlayerState.updatePlayerDeck(roomName, [], 'effects', myID);
    await Game.updatePlayOutCard(roomName, null);
    print('мы закончили розыгрыш заклинаний');
}




  //единороги

  static Future<void> unicornAlluringNarwhal(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
 print('МАНЯЩИЙ НАРВАЛ');
    List<CardModel>? otherBonus = await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);

    if(otherBonus!.isNotEmpty){
      await DialogForGame.show(
          context, cardDescription['МАНЯЩИЙ НАРВАЛ']!, roomName, otherBonus, myID, otherID,
          ScrollForGame(
              cards: otherBonus, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
                await Player.moveCardFromPDToPD(card!, roomName, 'bonuses', 'bonuses', otherID, myID);
              }));
    }

  }

  static Future<void> unicornGreatNarwhal(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    List<CardModel> deck =[];
     List<CardModel> card = await GameState.getDeck(roomName, 'deck');

     List<CardModel> unicorn = card.where((card)=> card.type== CardClass.unicorn).toList();

     for(int i =0; i<unicorn.length; i++){
       if(narwhalUnicorns.contains(unicorn[i].name)){
         deck.add(unicorn[i]);
       }
    }

     if(deck.isNotEmpty){
       await DialogForGame.show(context, cardDescription['ВЕЛИКИЙ НАРВАЛ']!, roomName, deck, myID, otherID,
           ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
               onCardTap: (context, CardModel? card)async{
             await Player.moveCardFromGDToPD(card!, roomName, 'deck', 'hand', myID);
               }));
     } else{
       await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
     }

  }



  static Future<void> unicornImpressiveNarwhal(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    List<CardModel> cards = await GameState.getDeck(roomName, 'deck');

    List<CardModel> deck = cards.where((card)=> card.type== CardClass.bonus).toList();
    print('как много бонусов в итоге${deck.length}');

    if(deck.isNotEmpty){
      await DialogForGame.show(context, cardDescription['ИМПОЗАНТНЫЙ НАРВАЛ']!, roomName, deck, myID, otherID,
          ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
                await Player.moveCardFromGDToPD(card!, roomName, 'deck', 'hand', myID);
              }));
    } else{
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }
  }

  static Future<void> unicornEmergencyNarwhal(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    List<CardModel> cards = await GameState.getDeck(roomName, 'deck');

    List<CardModel> deck = cards.where((card)=> card.type== CardClass.fine).toList();
    print('как много fines в итоге${deck.length}');

    if(deck.isNotEmpty){
      await DialogForGame.show(context, cardDescription['АВРАЛЬНЫЙ НАРВАЛ']!, roomName, deck, myID, otherID,
          ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
                await Player.moveCardFromGDToPD(card!, roomName, 'deck', 'hand', myID);
              }));
    } else{
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }
  }

  static Future<void> unicornTorpedoNarwhal(
      BuildContext context,
      String roomName,
      String myID,
      ) async{

    await PlayerState.updatePlayerDeck(roomName, [], 'fines', myID);
  }

  static Future<void> unicornMagicWing(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    List<CardModel> cards = await GameState.getDeck(roomName, 'discardPile');

    List<CardModel> deck = cards.where((card)=> card.type== CardClass.spell).toList();
    print('как много spell в итоге${deck.length}');

    if(deck.isNotEmpty){
      await DialogForGame.show(context, cardDescription['ВОЛШЕБНЫЙ КРЫЛОРОГ']!, roomName, deck, myID, otherID,
          ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
                await Player.moveCardFromGDToPD(card!, roomName, 'discardPile', 'hand', myID);
              }));
    } else{
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }

  }
  
  
  static Future<void> unicornJetWing(
      BuildContext context,
      String roomName,
      String myID,
      ) async{
    List<CardModel> cards = await GameState.getDeck(roomName, 'discardPile');

    List<CardModel> deck = cards.where((card)=> card.type== CardClass.tpru).toList();
    print('как много spell в итоге${deck.length}');


    if(deck.isNotEmpty){
      for(int i =0; i<deck.length; i++){
        if(deck[i].id == '15tpru'){
          deck.remove(deck[i]);
        }
      }
      CardModel card = deck.first;
      await Player.moveCardFromGDToPD(card, roomName, 'discardPile', 'hand', myID);

    } else{
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }

  }

  static Future<void> unicornInfuriatingWing(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? cards = await PlayerState.getPlayerDeck(roomName, 'hand', myID);

    if(cards!.isNotEmpty){
      await DialogForGame.show(context, cardDescription['БЕСЯЧИЙ КРЫЛОРОГ']!, roomName, cards, myID, otherID,
          ScrollForGame(cards: cards, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
            await Player.cardDiscard(context, roomName, card!, myID);
              }));

    } else{
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }

  }

  static Future<void> unicornMermaidHorn(
      BuildContext context,
  String roomName,
  String myID,
  String otherID,
  ) async {
  print('мы на розыгрыше карт РУСАЛКОРОГ');
  List<CardModel> allMyCard = [];
  List<CardModel>? myStall =
  await PlayerState.getPlayerDeck(roomName, 'stall', myID);
  if (myStall!.isNotEmpty) {
  allMyCard.addAll(myStall);
  }
  List<CardModel>? myBonus =
  await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
  if (myBonus!.isNotEmpty) {
  allMyCard.addAll(myBonus);
  }
  List<CardModel>? myFines =
  await PlayerState.getPlayerDeck(roomName, 'fines', myID);
  if (myFines!.isNotEmpty) {
  allMyCard.addAll(myFines);
  }

  if (allMyCard!.isNotEmpty) {
  await DialogForGame.show(
  context,
  cardDescription['РУСАЛКОРОГ']!,
  roomName,
  allMyCard,
  myID,
  otherID,
  ScrollForGame(cards: allMyCard,
  roomName: roomName,
  myID: myID,
  countDiscard: 1,
  onCardTap: (context, CardModel? card) async {
  await Player.takeCardOnHand(card!, roomName, myID);
  }));

  }
  }

  static Future<void> unicornLamaHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? cards = await PlayerState.getPlayerDeck(roomName, 'hand', myID);

    if(cards!.isNotEmpty){
      await DialogForGame.show(context, cardDescription['ЛАМАРОГ']!, roomName, cards, myID, otherID,
          ScrollForGame(cards: cards, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
                await Player.cardDiscard(context, roomName, card!, myID);
              }));
    }

  }

  static Future<void> unicornPretentiousWing(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    
    List<CardModel> cards = await GameState.getDeck(roomName, 'discardPile');
    
    List<CardModel> deck = cards.where((card)=> card.type == CardClass.unicorn).toList();
    
    if(deck.isNotEmpty){
      await DialogForGame.show(context, cardDescription['ПАФОСНЫЙ КРЫЛОРОГ']!, roomName, deck, myID, otherID, 
          ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1, 
              onCardTap: (contex, CardModel? card)async{
            await Player.moveCardFromGDToPD(card!, roomName, 'discardPile', 'hand', myID);
              }));
    }else{
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }
  }

  static Future<void> unicornGreedyWing(
      String roomName,
      String myID,
      ) async{
    List<CardModel>? deck = await GameState.getDeck(roomName, 'deck');
    
    await Player.moveCardFromGDToPD(deck[deck.length-1], roomName, 'deck', 'hand', myID);
    
  }


   static Future<void> unicornCobHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
     List<CardModel> takeCard = await GameState.getDeck(roomName, 'deck');
     String? description = cardDescription['ПОЧАТОК РОГ'];


     for (int i = 0; i < 2; i++) {
       CardModel card = takeCard[takeCard.length -1 - i];
       await Player.moveCardFromGDToPD(card, roomName, 'deck', 'hand', myID);
     }

     List<CardModel>? deck =
     await PlayerState.getPlayerDeck(roomName, 'hand', myID);

     await DialogForGame.show(
         context,
         description!,
         roomName,
         deck,
         myID,
         otherID,
         ScrollForGame(
             cards: deck,
             roomName: roomName,
             myID: myID,
             countDiscard: 1,
             onCardTap: (BuildContext context, CardModel? card) async {
               await Player.cardDiscard(context, roomName, card!, myID);
             }));
   }

  static Future<void> unicornChainsawHorn(
      BuildContext context,
      String roomName,
      String otherID,
      ) async{
  }

  static Future<void> unicornKnifeHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async {
    List<CardModel>? deck = await PlayerState.getPlayerDeck(
        roomName, 'stall', otherID);

    if (deck!.isNotEmpty) {
      await DialogForGame.show(context, cardDescription['НОЖЕРОГ']!, roomName, deck, myID, otherID,
          ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
              onCardTap: (context, CardModel? card)async{
            await Player.destroyUnicorn(card, roomName, otherID);
              }));
    } else {
      await DialogWindow.show(context,checkText['unicorn']!, titleForDialogWindow);
    }
  }

  static Future<void> unicornDarkAngelHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? deckForSacrifice = await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    CardModel? card = deckForSacrifice!.firstWhere((card)=> card.name =='ТЕМНЫЙ АНГЕЛОРОГ');
    deckForSacrifice.remove(card);

    await DialogForGame.show(context, cardDescription['ТЕМНЫЙ АНГЕЛОРОГ']!, roomName, deckForSacrifice, myID, otherID,
         ScrollForGame(cards: deckForSacrifice, roomName: roomName, myID: myID, countDiscard: 1,
             onCardTap: (context, CardModel? card)async{
           await Player.sacrificeUnicorn(roomName, card!, myID);
             }));

    List<CardModel>? deckForAdd = await GameState.getDeck(roomName, 'discardPile');
    List<CardModel>? deck = deckForAdd.where((card)=>card.type == CardClass.unicorn).toList();

     if(deck.isNotEmpty) {
       await DialogForGame.show(
           context,
           cardDescription['ТЕМНЫЙ АНГЕЛОРОГ1']!,
           roomName,
           deck,
           myID,
           otherID,
           ScrollForGame(cards: deck,
               roomName: roomName,
               myID: myID,
               countDiscard: 1,
               onCardTap: (context, CardModel? card) async {
                 await Player.moveCardFromGDToPD(
                     card!, roomName, 'discardPile', 'stall', myID);
               }));
     } else {
       await DialogWindow.show(context, checkText['unicorn']!, titleForDialogWindow);
     }


  }

  static Future<void> unicornOracle(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    List<CardModel>? cards = await GameState.getDeck(roomName, 'deck');

    List<CardModel>? deck = [];

    for(int i =0; i<3; i++){
      deck.add(cards[cards.length-1-i]);
    }

    await DialogForGame.show(context, cardDescription['ОРАКУЛОРОГ']!, roomName, cards, myID, otherID,
        ScrollForGame(cards: deck, roomName: roomName, myID: myID, countDiscard: 1,
            onCardTap: (context, CardModel? card) async{
          await Player.moveCardFromGDToPD(card!, roomName, 'deck', 'hand', myID);
            }));
  }

  static Future<void> unicornAmerican(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async {
    List<CardModel>? cards = await PlayerState.getPlayerDeck(
        roomName, 'stall', otherID);

    int countCard = cards!.length;
    if (cards.isNotEmpty) {
      List<CardModel>? deck = [];
      for (int i = 0; i < countCard; i++) {
        deck.add(
            CardModel('$i', '$i', CardClass.baby, 'assets/suit.png', '$i'));
      }

      await DialogForGame.show(
          context,
          cardDescription['АМЕРИРОГ']!,
          roomName,
          deck,
          myID,
          otherID,
          ScrollForGame(cards: deck,
              roomName: roomName,
              myID: myID,
              countDiscard: 1,
              onCardTap: (context, CardModel? card) async {
                await Player.moveCardWithIndex(roomName, otherID, myID);
              }));
    }
  }


  static Future<void> unicornSharkHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? cards = await PlayerState.getPlayerDeck(roomName, 'stall', otherID);

if(cards!.isNotEmpty){
  print('разыгрываем акулорога');
  await DialogForNo.show(context, cardDescription['АКУЛОРОГ']!, myID, otherID, roomName, 'Play or no?',
      ScrollForMovingCard(cards: cards, roomName: roomName, myID: myID, countDiscard: 1,
        onCardTap: (context, CardModel? card)async{
          await Player.destroyUnicorn(card, roomName, otherID);}),
      ()async{
        List<CardModel>? cards = await PlayerState.getPlayerDeck(roomName, 'stall', myID);
CardModel? shark = cards?.firstWhere((card)=> card.name == 'АКУЛОРОГ');
await Player.sacrificeUnicorn(roomName, shark, myID);
      });
}

    }
    
    
    static Future<void> unicornBillHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async {
      if (Provider
          .of<GameDataProvider>(context, listen: false)
          .actCount == 0) {
        List<CardModel>? cards = await PlayerState.getPlayerDeck(
            roomName, 'stall', otherID);

        if (cards!.isNotEmpty) {
          await DialogForGame.show(
              context,
              cardDescription['НОСОРОГОРОГ']!,
              roomName,
              cards,
              myID,
              otherID,
              ScrollForGame(cards: cards,
                  roomName: roomName,
                  myID: myID,
                  countDiscard: 1,
                  onCardTap: (context, CardModel? card) async {
                    await Player.destroyUnicorn(card!, roomName, otherID);
                  }));
        }

        await Game.incrementActCount(roomName);
        await Game.incrementActCount(roomName);
      }
    }

    static Future<void> unicornDestructionHorn(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? cards = await PlayerState.getPlayerDeck(roomName, 'stall', myID);

if(cards!.isNotEmpty){
  await DialogForGame.show(context, cardDescription['КРУШЕРОГ']!, roomName, cards, myID, otherID,
      ScrollForGame(cards: cards, roomName: roomName, myID: myID, countDiscard: 1,
          onCardTap: (context, CardModel? card)async{
        await Player.sacrificeUnicorn(roomName, card!, myID);
          }));

}
    }
    


  static Future<void> playOutUnicorn(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,
      ) async {
    print('разыгырваемая карта в плэйUnicorn ${card?.name}');

    CardModel? jump;
    String currentPlayer = Provider.of<CurrentPlayerState>(context, listen: false).currentPlayer;
    List<CardModel>? fines = await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    List<CardModel>? bonuses = await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    List<CardModel>? effects = await PlayerState.getPlayerDeck(roomName, 'effects', myID);
    bool isEven = fines?.any((card)=> card.name =='СЛЕПЯЩИЙ СВЕТ') ?? false;
    bool isEven2 = fines?.any((card)=> card.name =='ПАНДЕЦ') ?? false;

    bool isEvenJump = bonuses?.any((card)=> card.name =='ПРЫГ-СКОК') ?? false;
    print('есть ли карта ПРЫГ-СКОК $isEvenJump ');
    bool isEvenEffects = effects?.any((card)=> card.name =='ПРЫГ-СКОК') ?? false;
    print('есть ли карта in effects $isEvenEffects ');

    if(isEvenEffects){
      jump = effects?.firstWhere((card)=> card.name =='ПРЫГ-СКОК');
      print('jump ${jump!.name} ');

    }

    await PlayerState.addCardPlayerDeck(roomName, card!, 'stall', currentPlayer);
if(!isEven2 && !isEven) {
  if (card.name == 'МАНЯЩИЙ НАРВАЛ') {
    print('мы на условии что это МАНЯЩИЙ НАРВАЛ');
    await unicornAlluringNarwhal(context, roomName, myID, otherID);
  } else if (card.name == 'ВЕЛИКИЙ НАРВАЛ') {
    print('мы на условии что это ВЕЛИКИЙ НАРВАЛ');
    await unicornGreatNarwhal(context, roomName, myID, otherID);
  } else if (card.name == 'ИМПОЗАНТНЫЙ НАРВАЛ') {
    print('мы на условии что это ИМПОЗАНТНЫЙ НАРВАЛ');
    await unicornImpressiveNarwhal(context, roomName, myID, otherID);
  } else if (card.name == 'АВРАЛЬНЫЙ НАРВАЛ') {
    print('мы на условии что это АВРАЛЬНЫЙ НАРВАЛ');
    await unicornEmergencyNarwhal(context, roomName, myID, otherID);
  } else if (card.name == 'ВОЛШЕБНЫЙ КРЫЛОРОГ') {
    print('мы на условии что это ВОЛШЕБНЫЙ КРЫЛОРОГ');
    await unicornMagicWing(context, roomName, myID, otherID);
  } else if (card.name == 'РЕАКТИВНЫЙ КРЫЛОРОГ') {
    print('мы на условии что это РЕАКТИВНЫЙ КРЫЛОРОГ');
    await unicornJetWing(context, roomName, myID);
  } else if (card.name == 'ПАФОСНЫЙ КРЫЛОРОГ') {
    print('мы на условии что это ПАФОСНЫЙ КРЫЛОРОГ');
    await unicornPretentiousWing(context, roomName, myID, otherID);
  } else if (card.name == 'ПОЧАТОК РОГ') {
    print('мы на условии что это ПОЧАТОК РОГ');
    await unicornCobHorn(context, roomName, myID, otherID);
  } else if (card.name == 'ТЕМНЫЙ АНГЕЛОРОГ') {
    print('мы на условии что это ТЕМНЫЙ АНГЕЛОРОГ');
    await unicornDarkAngelHorn(context, roomName, myID, otherID);
  } else if (card.name == 'ОРАКУЛОРОГ') {
    print('мы на условии что это ОРАКУЛОРОГ');
    await unicornOracle(context, roomName, myID, otherID);
  } else if (card.name == 'АМЕРИРОГ') {
    print('мы на условии что это АМЕРИРОГ');
    await unicornAmerican(context, roomName, myID, otherID);
  } else if (card.name == 'ЖАДНЫЙ КРЫЛОРОГ') {
    print('мы на условии что это ЖАДНЫЙ КРЫЛОРОГ');
    await unicornGreedyWing(roomName, myID);
  }else if (card.name == 'ЛАМАРОГ') {
    print('мы на условии что это ЛАМАРОГ');
    await unicornLamaHorn(context, roomName, myID, otherID);
  }else if (card.name == 'НОСОРОГОРОГ') {
    print('мы на условии что это НОСОРОГОРОГ');
    await unicornBillHorn(context, roomName, myID, otherID);
  }else if (card.name == 'КРУШЕРОГ') {
    print('мы на условии что это КРУШЕРОГ');
    await unicornDestructionHorn(context, roomName, myID, otherID);
  }
}
if (card.name == 'ТОРПЕДНЫЙ НАРВАЛ') {
  print('мы на условии что это ТОРПЕДНЫЙ НАРВАЛ');
  await unicornTorpedoNarwhal(context, roomName, myID);
}else if (card.name == 'БЕНЗОПИЛОРОГ') {
  print('мы на условии что это БЕНЗОПИЛОРОГ');
  await spellAttack(context, roomName, myID, otherID);
}

    await Game.changeGameStatus('inProcess', roomName);
if(!isEvenJump || isEvenEffects) {
  await Game.checkCountCardOnHand(
    context,
    roomName,
    'hand',
    Provider
        .of<CurrentPlayerState>(context, listen: false)
        .currentPlayer,
    myID,
    otherID,
  );
} else{
  await Game.decreaseActCount(roomName);
  await PlayerState.addCardPlayerDeck(roomName, jump!, 'effects', myID);
}
await PlayerState.updatePlayerDeck(roomName, [], 'effects', myID);
    await Game.updatePlayOutCard(roomName, null);
    print('мы закончили розыгрыш единорога');
  }

  static Future<void> playOutUnicornForNoCurrentPlayer(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,
      ) async {
    await Game.changeGameStatus('inProcess', roomName);
    if (card!.name == 'БЕСЯЧИЙ КРЫЛОРОГ') {
      print('мы на условии что это БЕСЯЧИЙ КРЫЛОРОГ');
      await unicornInfuriatingWing(context, roomName, myID, otherID);
    } else if (card.name == 'ЛАМАРОГ') {
      print('мы на условии что это ЛАМАРОГ');
      await unicornLamaHorn(context, roomName, myID, otherID);
    } else if (card.name == 'КРУШЕРОГ') {
      print('мы на условии что это КРУШЕРОГ');
      await unicornDestructionHorn(context, roomName, myID, otherID);
    }else if (card.name == 'РУСАЛКОРОГ') {
      print('мы на условии что это РУСАЛКОРОГ');
      await unicornMermaidHorn(context, roomName, myID, otherID);
    }
  }





  //бонусы

  static Future<void> bonusesRainbowLasso(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? hand = await PlayerState.getPlayerDeck(roomName, 'hand', myID);
    List<CardModel>? otherStall = await PlayerState.getPlayerDeck(roomName, 'stall', otherID);

    await DialogForGame.show(context, cardDescription['РАДУЖНОЕ ЛАССО']!, roomName, hand, myID, otherID,
ScrollForMultiDiscard(
    cards: hand, roomName: roomName, myID: myID, countDestroy: 3));


    await DialogForGame.show(context, cardDescription['РАДУЖНОЕ ЛАССО1']!, roomName, otherStall, myID, otherID,
        ScrollForGame(cards: otherStall, roomName: roomName, myID: myID, countDiscard: 1,
            onCardTap: (context, CardModel? card)async{
          await Player.moveCardFromPDToPD(card!, roomName, 'stall', 'stall', otherID, myID);
            }));
  }

  static Future<void> bonusesDiscoBomb(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel> allMyCard = [];

    List<CardModel>? myStall =
    await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    if (myStall!.isNotEmpty) {
      allMyCard.addAll(myStall);
    }
    List<CardModel>? myBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    if (myBonus!.isNotEmpty) {
      allMyCard.addAll(myBonus);
    }
    List<CardModel>? myFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    if (myFines!.isNotEmpty) {
      allMyCard.addAll(myFines);
    }

    //проверяем есть ли бонус радужная аура
    List<CardModel> allOtherCard = [];
    bool isEven =
    await CheckPossibility.checkRainbowAura(roomName, otherID, context);
    if (!isEven) {
      List<CardModel>? otherStall =
      await PlayerState.getPlayerDeck(roomName, 'stall', otherID);
      if (otherStall!.isNotEmpty) {
        allOtherCard.addAll(otherStall);
      }
    }

    List<CardModel>? otherBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', otherID);
    if (otherBonus!.isNotEmpty) {
      allOtherCard.addAll(otherBonus);
    }
    List<CardModel>? otherFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', otherID);
    if (otherFines!.isNotEmpty) {
      allOtherCard.addAll(otherFines);
    }

    await DialogForGame.show(
        context,
        cardDescription['ДИСКОБОМБА']!,
        roomName,
        allMyCard,
        myID,
        otherID,
        ScrollForSacrifice(
            cards: allMyCard,
            roomName: roomName,
            myID: myID,
            countDiscard: 1));

    await DialogForGame.show(
      context,
      cardDescription['ДИСКОБОМБА1']!,
      roomName,
      allOtherCard,
      myID,
      otherID,
      ScrollForDestroy(
          cards: allOtherCard,
          roomName: roomName,
          myID: myID,
          otherID: otherID,
          countDestroy: 1),
    );
  }

  static Future<void> bonusesArtabstall(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{
    List<CardModel>? hand = await PlayerState.getPlayerDeck(roomName, 'hand', myID);
    List<CardModel>? otherStall = await PlayerState.getPlayerDeck(roomName, 'stall', otherID);

    await DialogForGame.show(context, cardDescription['АРТАБСТОЙЛО']!, roomName, hand, myID, otherID,
        ScrollForMultiDiscard(cards: hand, roomName: roomName, myID: myID, countDestroy: 2));

    await DialogForGame.show(context, cardDescription['АРТАБСТОЙЛО1']!, roomName, otherStall, myID, otherID,
        ScrollForGame(cards: otherStall, roomName: roomName, myID: myID, countDiscard: 1,
            onCardTap: (context, CardModel? card)async{
              await Player.destroyUnicorn(card!, roomName, otherID);
            }));

  }

  static Future<void> bonusesGrabGrab(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel>? deck = await GameState.getDeck(roomName, 'deck');
    CardModel? card = deck[deck.length-1];
    List<CardModel>? hand = await PlayerState.getPlayerDeck(roomName, 'hand', myID);

    await DialogForGame.show(context, cardDescription['ХВАТЬ-ХВАТЬ']!, roomName, hand, myID, otherID,
        ScrollForGame(cards: hand, roomName: roomName, myID: myID, countDiscard: 1,
            onCardTap: (context, CardModel? card)async{
              await Player.cardDiscard(context, roomName, card!, myID);
            }));

    await PlayerState.addCardPlayerDeck(roomName, card, 'hand', myID);
    await GameState.removeCardGameDeck(roomName, card, 'deck');

  }

  static Future<void> bonusesCaffeineDebauchery(
      BuildContext context,
      String roomName,
      String myID,
      String otherID,
      ) async{

    List<CardModel> allMyCard = [];

    List<CardModel>? myStall =
    await PlayerState.getPlayerDeck(roomName, 'stall', myID);
    if (myStall!.isNotEmpty) {
      allMyCard.addAll(myStall);
    }
    List<CardModel>? myBonus =
    await PlayerState.getPlayerDeck(roomName, 'bonuses', myID);
    if (myBonus!.isNotEmpty) {
      allMyCard.addAll(myBonus);
    }
    List<CardModel>? myFines =
    await PlayerState.getPlayerDeck(roomName, 'fines', myID);
    if (myFines!.isNotEmpty) {
      allMyCard.addAll(myFines);
    }

    await DialogForGame.show(
        context,
        cardDescription['КОФЕЙНЫЙ ДЕБОШ']!,
        roomName,
        allMyCard,
        myID,
        otherID,
        ScrollForSacrifice(
            cards: allMyCard,
            roomName: roomName,
            myID: myID,
            countDiscard: 1));

    List<CardModel>? deck = await GameState.getDeck(roomName, 'deck');


    for(int i =0; i<2; i++){
      CardModel? card = deck[deck.length-1-i];
      await PlayerState.addCardPlayerDeck(roomName, card, 'hand', myID);
      await GameState.removeCardGameDeck(roomName, card, 'deck');
    }

  }


  static Future<void> playOutBonuses(
      BuildContext context,
      String roomName,
      CardModel? card,
      String myID,
      String otherID,
      ) async{
    await Game.changeGameStatus('inProcess', roomName);
    if(card?.name == 'ХВАТЬ-ХВАТЬ'){
      print('на плэй бонус ХВАТЬ-ХВАТЬ ');
      await bonusesGrabGrab(context, roomName, myID, otherID);
    } else if(card?.name == 'АРТАБСТОЙЛО'){
      print('на плэй бонус АРТАБСТОЙЛО ');
      await bonusesArtabstall(context, roomName, myID, otherID);

    }else if(card?.name == 'ДИСКОБОМБА'){
      print('на плэй бонус ДИСКОБОМБА ');
      await bonusesDiscoBomb(context, roomName, myID, otherID);

    }else if(card?.name == 'КОФЕЙНЫЙ ДЕБОШ'){
      print('на плэй бонус КОФЕЙНЫЙ ДЕБОШ ');
      await bonusesCaffeineDebauchery(context, roomName, myID, otherID);

    }else if(card?.name == 'РАДУЖНОЕ ЛАССО'){
      print('на плэй бонус РАДУЖНОЕ ЛАССО ');
      await bonusesRainbowLasso(context, roomName, myID, otherID);
    }
    await Game.changeGameStatus('inProcess', roomName);
    print('мы закончили розыгрыш бонуса');


  }
}

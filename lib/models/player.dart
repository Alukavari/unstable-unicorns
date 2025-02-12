import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/models/player_state.dart';
import 'package:unstable_unicorns/services/dialog/dialog_kill_tpru.dart';
import 'package:unstable_unicorns/services/dialog/dialog_window.dart';
import '../const/const.dart';
import '../const/immortal_unicorns.dart';
import '../services/dialog/dialog_for_TPRU.dart';
import '../services/dialog/dialog_whithoutTPRU.dart';
import 'card.dart';
import 'chek_possibility.dart';
import 'game.dart';
import 'game_state.dart';

class Player {
  //разыгрываем карту
  static Future<void> playCard(BuildContext context,
      String roomName,
      String currentPlayer,
      String myID,
      String otherID,) async {
    CardModel? newCard = await Game.getPlayOutCard(roomName);
    print('разыгрываемая карта в плэйкард ${newCard?.name}');

    if (newCard?.type == CardClass.tpru) {
      DialogWindow.show(
          context, 'You can\'t play TPRU, choose another card', titleForDialogWindow);
    } else {
      await GameState.updateWithNewCardGameDeck(
        roomName,
        newCard!,
        'playingCardOnTable',
      );

      await PlayerState.removeCardFromPlayerDeck(
        roomName,
        newCard,
        'hand',
        currentPlayer,
      );
      await Game.nextPlayer(
        roomName,
        currentPlayer,
        myID,
        otherID,
      );

      await Game.changeGameStatus(
        'checkTPRU',
        roomName,
      );
    }
  }

  //проверка на наличие тпру у игрока
  static Future<void> checkTPRU(
      BuildContext context,
      String currentPlayer,
      String myID,
      String otherID,
      String roomName,) async {
// получаем значение разыгрываемой карты
    CardModel? newCard = await Game.getPlayOutCard(roomName);
    print('разыгрываемая карта в чектпру ${newCard?.name}');
    CardModel? tpru;
    CardModel? tpruKill;

    List<CardModel> handCards = await PlayerState.getPlayerDeck(
      roomName,
      'hand',
      currentPlayer,
    ) as List<CardModel>;

    List<CardModel> stallDeck = await PlayerState.getPlayerDeck(
      roomName,
      'stall',
      currentPlayer,
    ) as List<CardModel>;

    bool hasTpruCard = handCards.any((card) =>
    card.type == CardClass.tpru && card.id != '15tpru');
    bool hasTpruCardKill = handCards.any((card) => card.id == '15tpru');
    bool hasNoTpruUnicorn = stallDeck.any((card) => card.name == 'ЖИРНОРОГ');
    //если нет штрафа то все ок если есть штраф то фалсе
    bool hasSun = await CheckPossibility.checkHaveSun(roomName, myID);

    if (hasTpruCardKill) {
      tpruKill = handCards.firstWhere((card) => card.id == '15tpru');
    }

    if (hasTpruCard) {
      tpru = handCards.firstWhere((card) => card.type == CardClass.tpru &&
          card.id != '15tpru');
      print('есть ли тпру ${tpru.name}');
    }
    //add
    if (!hasNoTpruUnicorn || hasSun) {
      if (hasTpruCard || hasTpruCardKill) {
        if (hasTpruCard && hasTpruCardKill) {
          await DialogForKillTPRU.show(
              context,
              currentPlayer,
              myID,
              otherID,
              newCard,
              tpru!,
              tpruKill!,
              handCards,
              roomName);
        } else if (hasTpruCardKill && !hasTpruCard) {
          await DialogForTPRU.show(
              context,
              tpruKill!,
              currentPlayer,
              myID,
              otherID,
              newCard,
              roomName);
        } else{
          await DialogForTPRU.show(
            context,
            tpru!,
            currentPlayer,
            myID,
            otherID,
            newCard,
            roomName,
          );
        }
      } else {
        await DialogWithoutTPRU.show(
          context,
          roomName,
          myID,
          otherID,
          newCard,
        );
      }
    }
  }

//разыгрываем функцию карты
  static Future<void> activateCard(BuildContext context,
      CardModel newCard,
      String roomName,
      String myID,
      String otherID,
      ) async {

    if (newCard.type == CardClass.unicorn) {
      print('тип карты единорог');
      await GameState.removeCardGameDeck(
        roomName,
        newCard,
        'playingCardOnTable',
      );
      print('поменяли статус в единороге');
      await Game.changeGameStatus('playOutUnicorn', roomName);
    }
    else if (newCard.type == CardClass.spell) {
      print('тип карты заклинание');
      await Game.changeGameStatus('playOutSpell', roomName);
      print('поменяли статус в заклинании');

    }
    else if (newCard.type == CardClass.bonus) {
      print('тип карты бонус');
      await CardModel.playOutBonusOnDeck(
          context, roomName, newCard, myID, otherID);
    }
    else if (newCard.type == CardClass.fine) {
      print('тип карты штраф');
      await CardModel.playOutFinesOnDeck(context, roomName, newCard, myID, otherID);
    }
  }


  static Future<bool> checkCardOnTableForDraw(String roomName) async {
    try {
      List<CardModel> cardOnTable =
      await GameState.getDeck(roomName, 'playingCardOnTable');

      int countCard = cardOnTable.length;
      return countCard % 2 == 0 ? true : false;
    } catch (e) {
      print('Error fetching cards from table: $e');
      return false;
    }
  }


// сбросить карту в сброс
  static Future<void> cardDiscard(BuildContext context,
      String roomName,
      CardModel newCard,
      String myID,) async {
    await GameState.updateWithNewCardGameDeck(
        roomName, newCard, 'discardPile');
    await PlayerState.removeCardFromPlayerDeck(
        roomName, newCard, 'hand', myID);
  }

//уничтожить единорога соперника
  static Future<void> destroyUnicorn(
      BuildContext context,
      CardModel? destroyCard,
      String roomName,
      String otherID,
      String myID,

      ) async {
    List<CardModel>? stall = await PlayerState.getPlayerDeck(
        roomName, 'stall', otherID);

    bool isEvenArmoredHorn = stall?.any((card) =>
    card.name == 'ЧЕРНЫЙ БРОНЕРОГ') ?? false;
    print('есть ли в дестрой бронерог$isEvenArmoredHorn');

    if (!isEvenArmoredHorn) {
      if (immortalUnicorns.contains(destroyCard!.name)) {
        print('Имя карты "${destroyCard.name}" совпадает с одним из известных имен единорогов.');
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', otherID);
        await PlayerState.addCardPlayerDeck(
            roomName, destroyCard, 'hand', otherID);

        //fireWire
        await Game.changeGameStatus('fineWire', roomName);

      } else if (
      destroyCard.name == 'ФЕНИКСОРОГ') {
        print('убиваемый единорожек ФЕНИКСОРОГ');
        CardModel? armoredHorn = stall!.firstWhere((card) =>
        card.name == 'ФЕНИКСОРОГ');
        print('чему равна сохраненная карта в фениксороге ${armoredHorn.name}');
        await Game.updatePlayOutCard(roomName, armoredHorn);
        await Game.changeGameStatus('playOutUnicornReaction', roomName);
      } else if (destroyCard.name == 'НОЖЕРОГ') {
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', otherID);
        await GameState.updateWithNewCardGameDeck(
            roomName, destroyCard, 'discardPile');
        CardModel? armoredHorn = stall!.firstWhere((card) =>
        card.name == 'НОЖЕРОГ');
        print('чему равна сохраненная карта в НОЖЕРОГ ${armoredHorn.name}');
        await Game.updatePlayOutCard(roomName, armoredHorn);

        // fireWire
        await Game.changeGameStatus('fineWire', roomName);

        await Game.changeGameStatus(
            'playOutUnicornReaction', roomName);
      } else if (
      destroyCard.type != CardClass.baby) {
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', otherID);
        print('убиваемый единорожек это не малыш');
        await GameState.updateWithNewCardGameDeck(
            roomName,
            destroyCard,
            'discardPile');
//fireWire
        await Game.changeGameStatus('fineWire', roomName);

      } else {
        print('убиваем черного бронерога и не малышей');
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', otherID);
        //fireWire
        await Game.changeGameStatus('fineWire', roomName);
      }
    } else if (destroyCard!.name == 'ЧЕРНЫЙ БРОНЕРОГ') {
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', otherID);
        print('убиваемый единорожек это не малыш');
        await GameState.updateWithNewCardGameDeck(
            roomName,
            destroyCard,
            'discardPile');
        //fireWire
        await Game.changeGameStatus('fineWire', roomName);
      } else {
        print('убиваемый единорожек не ЧЕРНЫЙ БРОНЕРОГ но черный броенрог есть');
        await Game.updateCardRemember(roomName, destroyCard);
        CardModel? remember = await Game.getCardRemember(roomName);
        print('получилось ли обновить новую карту в бронероге ${remember?.name}');
        CardModel? armoredHorn = stall!.firstWhere((card) =>
        card.name == 'ЧЕРНЫЙ БРОНЕРОГ');
        await Game.updatePlayOutCard(roomName, armoredHorn);
        await Game.changeGameStatus(
            'playOutUnicornReaction', roomName);
      }
    }

  //уничтожить бонус
  static Future<void> destroyBonus(CardModel? destroyCard,
      String roomName,
      String otherID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'bonuses',
        otherID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  // уничтожить штраф
  static Future<void> destroyFine(CardModel? destroyCard,
      String roomName,
      String otherID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'fines',
        otherID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  //уничтож или или
  static Future<void> destroyBonusOrFine(CardModel? destroyCard,
      String roomName,
      String otherID,
      String myID,) async {
    if (destroyCard?.type == CardClass.fine) {
      await Player.sacrificeFines(destroyCard, roomName, myID);
    }

    if (destroyCard?.type == CardClass.bonus) {
      await Player.destroyBonus(destroyCard, roomName, otherID);
    }
  }

//принести в жертву единорога
  static Future<void> sacrificeUnicorn(
      BuildContext context,
      roomName,
      destroyCard,
      myID,
      ) async {

    List<CardModel>? stall = await PlayerState.getPlayerDeck(
        roomName, 'stall', myID);

      if (immortalUnicorns.contains(destroyCard.name)) {
        await Game.updateCardRemember(roomName, destroyCard);
        print('Имя карты "${destroyCard.name}" совпадает с одним из известных имен единорогов.');
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', myID);
        await PlayerState.addCardPlayerDeck(
            roomName, destroyCard, 'hand', myID);

        // fineWire
        await Game.changeGameStatus('fireWire', roomName);


      }  else if (
      destroyCard.name == 'ФЕНИКСОРОГ') {
        await Game.updateCardRemember(roomName, destroyCard);
        print('destroyCard в плэер дестрой юникорн $destroyCard');
        print('приносим в жертву единорожек ФЕНИКСОРОГ');
        CardModel? armoredHorn = stall!.firstWhere((card)=> card.name == 'ФЕНИКСОРОГ');
        print('чему равна сохраненная карта в жертве ФЕНИКСОРОГ ${armoredHorn.name}');
        await Game.updatePlayOutCard(roomName, armoredHorn);
        await Game.changeGameStatus('playOutUnicornMyReaction', roomName);

      } else if(destroyCard.name == 'НОЖЕРОГ') {
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', myID);
        await GameState.updateWithNewCardGameDeck(
            roomName, destroyCard, 'discardPile');
        // fineWire
        // await Game.changeGameStatus('fireWire', roomName);

        await Game.updateCardRemember(roomName, destroyCard);
        print('destroyCard в плэер дестрой юникорн $destroyCard');
        CardModel? armoredHorn = stall!.firstWhere((card)=> card.name == 'НОЖЕРОГ');
        print('чему равна сохраненная карта в жертве НОЖЕРОГ ${armoredHorn.name}');
        await Game.updatePlayOutCard(roomName, armoredHorn);
        await Game.changeGameStatus('playOutUnicornMyReaction', roomName);
        print('новая игровая карта в ножероге $armoredHorn');

      } else if (
      destroyCard.type != CardClass.baby) {
        await Game.updateCardRemember(roomName, destroyCard);
        print('destroyCard в плэер дестрой юникорн $destroyCard');
        print('убиваемый единорожек это не малыш');
        await GameState.updateWithNewCardGameDeck(
            roomName,
            destroyCard,
            'discardPile');
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', myID);

        // fineWire
        await Game.changeGameStatus('fireWire', roomName);

      } else {
        print('destroyCard в плэер дестрой юникорн $destroyCard');
        await PlayerState.removeCardFromPlayerDeck(
            roomName, destroyCard!, 'stall', myID);
        // fineWire
        await Game.changeGameStatus('fireWire', roomName);
      }
  }

  //принести в жертву бонус
  static Future<void> sacrificeBonus(CardModel? destroyCard,
      String roomName,
      String myID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'bonuses',
        myID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }

  //принести в жертву  штраф
  static Future<void> sacrificeFines(CardModel? destroyCard,
      String roomName,
      String myID,) async {
    await PlayerState.removeCardFromPlayerDeck(
        roomName,
        destroyCard!,
        'fines',
        myID);
    await GameState.updateWithNewCardGameDeck(
        roomName,
        destroyCard,
        'discardPile');
  }


  //переместить карту откуда-то куда-то на стол
  static Future<void> changeCardFromPlayerDeck(CardModel card,
      String roomName,
      String fromID,
      String toID,) async {
    if (card.type == CardClass.fine) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'fines', fromID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'fines', toID);
    } else if (card.type == CardClass.bonus) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'bonuses', fromID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'bonuses', toID);
    } else if (card.type == CardClass.unicorn) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'stall', fromID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'stall', toID);
    }
  }


// перенести карту из рук в руки, со стола в руки
  static Future<void> moveCardFromPDToPD(
      CardModel card,
      String roomName,
      String fromDeck,
      String toDeck,
      String fromID,
      String toID,
      ) async {
    print('move card ${card.name}');
    List<CardModel>? updatedStall1 = await PlayerState.getPlayerDeck(
        roomName, 'stall', toID);
    print('Updated stall do adding card: ${updatedStall1!.length}');

    print('Attempting to move card ${card.name} from $fromDeck to $toDeck');
    await PlayerState.removeCardFromPlayerDeck(
        roomName, card, fromDeck, fromID);
    await PlayerState.addCardPlayerDeck(roomName, card, toDeck, toID);

    List<CardModel>? updatedStall = await PlayerState.getPlayerDeck(
        roomName, 'stall', toID);
    print('Updated stall after adding card: ${updatedStall!.length}');
    // add play out card
    if (card.type != CardClass.baby) {
      await Game.updatePlayOutCard(roomName, card);

      CardModel? cards = await Game.getPlayOutCard(roomName);
      print('какую карту поместили в moveCardFromGDToPD ${cards!.name}');
    }
  }

  // взять карту из колоды игры на руки
  static Future<void> moveCardFromGDToPD(
      CardModel card,
      String roomName,
      String fromDeck,
      String toDeck,
      String toID,) async {
    print('что за карту перемещаем в moveCardFromGDToPD ${card.name}');
    await GameState.removeCardGameDeck(roomName, card, fromDeck);
    await PlayerState.addCardPlayerDeck(roomName, card, toDeck, toID);
    await Game.updatePlayOutCard(roomName, card);
    CardModel? cards = await Game.getPlayOutCard(roomName);
    print('какую карту поместили в moveCardFromGDToPD ${cards!.name}');

  }

  static Future<void> moveCardFromPDToGD(CardModel card,
      String roomName,
      String fromDeck,
      String toDeck,
      String fromID,
      ) async {
    print('что за карту перемещаем в moveCardFromGDToPD ${card.name}');
    await PlayerState.removeCardFromPlayerDeck(roomName, card, fromDeck, fromID);
await GameState.updateWithNewCardGameDeck(roomName, card, toDeck);
  }

  //all stall
  static Future<List<CardModel>?> takeAllCardOnStall(String roomName,
      String playerID,) async {
    List<CardModel> allCard = [];
    List<CardModel>? bonuses = [];
    List<CardModel>? stall = [];
    List<CardModel>? fines = [];

    bonuses = await PlayerState.getPlayerDeck(roomName, 'bonuses', playerID);
    if (bonuses!.isNotEmpty) {
      allCard.addAll(bonuses);
    }

    stall = await PlayerState.getPlayerDeck(roomName, 'stall', playerID);
    if (stall!.isNotEmpty) {
      allCard.addAll(stall);
    }

    fines = await PlayerState.getPlayerDeck(roomName, 'fines', playerID);
    if (fines!.isNotEmpty) {
      allCard.addAll(fines);
    }
    return allCard;
  }


  //взять карту любую со стола на руки
  static Future<List<CardModel>?> takeCardOnHand(
      CardModel card,
      String roomName,
      String playerID,
      ) async {
    if (card.type == CardClass.fine) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'fines', playerID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'hand', playerID);
    } else if (card.type == CardClass.bonus) {
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'bonuses', playerID);
      await PlayerState.addCardPlayerDeck(roomName, card, 'hand', playerID);
    } else if (card.type == CardClass.unicorn) {
        await PlayerState.removeCardFromPlayerDeck(
            roomName, card, 'stall', playerID);
        await PlayerState.addCardPlayerDeck(roomName, card, 'hand', playerID);
        bool isEven = await CheckPossibility.checkHaveWire(roomName, playerID);
        if(isEven) {
          print('проволока есть');

          //fineWire
          await Game.changeGameStatus('fireWire', roomName);
          print('поменяли статус');
        }
      } else if (card.type == CardClass.baby){
      await PlayerState.removeCardFromPlayerDeck(
          roomName, card, 'stall', playerID);
      bool isEven = await CheckPossibility.checkHaveWire(roomName, playerID);
      if(isEven) {
        print('проволока есть');
        await Game.changeGameStatus('fireWire', roomName);
        print('поменяли статус');
      }
    }
  }

  //получить колоду определенных карт из колоды игры
  static Future<List<CardModel>?> takeSpecificCardsFromGDTOPD(
      CardClass cardType,
      String roomName,
      String fromGD,) async {
    List<CardModel>? cards = [];

    List<CardModel> cardsGameDeck = await GameState.getDeck(roomName, fromGD);
    cards = cardsGameDeck.where((card) => card.type == cardType).toList();

    return cards;


  }

  static Future<void> moveCardWithIndex(
      String roomName,
      String otherID,
      String myID,
  ) async {

    List<CardModel>? deck = await PlayerState.getPlayerDeck(roomName, 'hand', otherID);
    Random random = Random();
   deck!.shuffle();
    int randomIndex = random.nextInt(deck.length-1);
    await moveCardFromPDToPD(deck[randomIndex], roomName, 'hand', 'hand', otherID, myID);
  }

  static Future<void> shuffleDeckWithNewCard(
      String roomName,
      CardModel? card,
      String typeDeck,
  ) async {

    List<CardModel>? deck = await GameState.getDeck(roomName, typeDeck);
    deck.add(card!);

    deck.shuffle();

    await GameState.updateDeck(roomName, deck, 'deck');
  }



}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'card.dart';

final List<CardModel> babyDeck = [
  CardModel(
      'Baby',
      'Если ты должен принести в жертву, уничтожить или вернуть на руку малыша-единорожка, вместо этого помести его в ясли',
      CardClass.baby,
      'assets/1m.png',
      '1m'),
  CardModel(
      'Baby',
      'Если ты должен принести в жертву, уничтожить или вернуть на руку малыша-единорожка, вместо этого помести его в ясли',
      CardClass.baby,
      'assets/2m.png',
      '2m'),
  CardModel(
      'Baby',
      'Если ты должен принести в жертву, уничтожить или вернуть на руку малыша-единорожка, вместо этого помести его в ясли',
      CardClass.baby,
      'assets/3m.png',
      '3m'),
  CardModel(
      'Baby',
      'Если ты должен принести в жертву, уничтожить или вернуть на руку малыша-единорожка, вместо этого помести его в ясли',
      CardClass.baby,
      'assets/4m.png',
      '4m'),
  CardModel(
      'Baby',
      'Если ты должен принести в жертву, уничтожить или вернуть на руку малыша-единорожка, вместо этого помести его в ясли',
      CardClass.baby,
      'assets/5m.png',
      '5m'),
  CardModel(
      'Baby',
      'Если ты должен принести в жертву, уничтожить или вернуть на руку малыша-единорожка, вместо этого помести его в ясли',
      CardClass.baby,
      'assets/6m.png',
      '6m'),
];

final List<CardModel> cards = [
  CardModel(
      'ХВАТЬ-ХВАТЬ',
      'В начале своего хода можешь сбросить 1 карту, а затем взять 1 карту',
      CardClass.bonus,
      'assets/1b.png',
      '1b'),
  CardModel(
      'ХВАТЬ-ХВАТЬ',
      'В начале своего хода можешь сбросить 1 карту, а затем взять 1 карту',
      CardClass.bonus,
      'assets/2b.png',
      '2b'),
  CardModel(
      'ХВАТЬ-ХВАТЬ',
      'В начале своего хода можешь сбросить 1 карту, а затем взять 1 карту',
      CardClass.bonus,
      'assets/3b.png',
      '3b'),
  CardModel(
      'АРТАБСТОЙЛО',
      ' В начале своего хода можешь сбросить 2 карты, а затем уничтожить 1 единорожка',
      CardClass.bonus,
      'assets/4b.png',
      '4b'),
  CardModel(
      'АРТАБСТОЙЛО',
      ' В начале своего хода можешь сбросить 2 карты, а затем уничтожить 1 единорожка',
      CardClass.bonus,
      'assets/5b.png',
      '5b'),
  CardModel(
      'АРТАБСТОЙЛО',
      ' В начале своего хода можешь сбросить 2 карты, а затем уничтожить 1 единорожка',
      CardClass.bonus,
      'assets/6b.png',
      '6b'),

  CardModel(
      'ДИСКОБОМБА',
      'В начале своего хода можешь принести в жертву 1 карту, а затем уничтожить 1 карту',
      CardClass.bonus,
      'assets/7b.png',
      '7b'),
  CardModel(
      'ДИСКОБОМБА',
      'В начале своего хода можешь принести в жертву 1 карту, а затем уничтожить 1 карту',
      CardClass.bonus,
      'assets/8b.png',
      '8b'),
   CardModel(
      'КОФЕЙНЫЙ ДЕБОШ',
      'В начале своего хода можешь принести в жертву 1 карту, а затем взять 2 карты',
      CardClass.bonus,
      'assets/10b.png',
      '10b'),
  CardModel('РАДУЖНАЯ РАДУГА', 'Твоих единорожков нельзя уничтожить',
      CardClass.bonus, 'assets/11b.png', '11b'),
  CardModel(
      'ПРЫГ-СКОК',
      'Если этот бонус стоит в твоем стойле в начале твоего хода, в фазе действий можешь сыграть 2 карты (вместо 1)',
      CardClass.bonus,
      'assets/12b.png',
      '12b'),
  CardModel(
      'РАДУЖНОЕ ЛАССО',
      'В начале своего хода можешь сбросить 3 карты, а затем украсть 1 единорожка',
      CardClass.bonus,
      'assets/13b.png',
      '13b'),

  CardModel(
      'СЛЕПЯЩИЙ СВЕТ',
      'Все твои единорожки считаются обычными, и их эффекты не срабатывают',
      CardClass.fine,
      'assets/1ff.png',
      '1ff'),
  CardModel(
      'ОТСТОЙЛО',
      'Ты не можешь играть бонусы',
      CardClass.fine,
      'assets/2ff.png',
      '2ff'),
  CardModel(
      'ПАНДЕЦ',
      'Все твои единорожки теперь считаются пандами. Все правила, касающиеся единорожков, не действуют на панд',
      CardClass.fine,
      'assets/3ff.png',
      '3ff'),
  CardModel(
      'КОЛЮЧАЯ ПРОВОЛКА',
      'Каждый раз, когда единорожек входит в твоё стойло или покидает его, сбрасывай 1 карту',
      CardClass.fine,
      'assets/4ff.png',
      '4ff'),
  CardModel(
      'МИНИ-СТОЙЛО',
      'Каждый раз, когда в твоём стойле оказывается больше 5 единорожков, приноси в жертву 1 единорожка',
      CardClass.fine,
      'assets/5ff.png',
      '5ff'),

  CardModel('ЕДИНОРОЖИЙ ЯД', 'Уничтожь 1 единорожка', CardClass.spell,
      'assets/1s.png', '1s'),
  CardModel('ЕДИНОРОЖИЙ ЯД', 'Уничтожь 1 единорожка', CardClass.spell,
      'assets/2s.png', '2s'),
  CardModel('ЕДИНОРОЖИЙ ЯД', 'Уничтожь 1 единорожка', CardClass.spell,
      'assets/3s.png', '3s'),
  CardModel(
      'БЛЕСТЯЩЕЕ ТОРНАДО',
      'Каждый игрок должен взять на руку 1 карту (на твой выбор) из своего стойла',
      CardClass.spell,
      'assets/4s.png',
      '4s'),
  CardModel(
      'БЛЕСТЯЩЕЕ ТОРНАДО',
      'Каждый игрок должен взять на руку 1 карту (на твой выбор) из своего стойла',
      CardClass.spell,
      'assets/5s.png',
      '5s'),
  CardModel(
      'ПИНОК',
      'Заставь другого игрока вернуть обратно на руку карту из его стойла. Затем этот игрок должен сбросить 1 карту',
      CardClass.spell,
      'assets/6s.png',
      '6s'),
  CardModel(
      'ПИНОК',
      'Заставь другого игрока вернуть обратно на руку карту из его стойла. Затем этот игрок должен сбросить 1 карту',
      CardClass.spell,
      'assets/7s.png',
      '7s'),
  CardModel(
      'ПИНОК',
      'Заставь другого игрока вернуть обратно на руку карту из его стойла. Затем этот игрок должен сбросить 1 карту',
      CardClass.spell,
      'assets/8s.png',
      '8s'),
  CardModel(
      'КЛЕВЕР-ПЕРЕВЁРТЫШ',
      'Возьми 2 карты, сбрось 3 карты, а затем немедленно соверши ещё 1 ход ',
      CardClass.spell,
      'assets/9s.png',
      '9s'),
  CardModel(
      'КЛЕВЕР-ПЕРЕВЁРТЫШ',
      'Возьми 2 карты, сбрось 3 карты, а затем немедленно соверши ещё 1 ход ',
      CardClass.spell,
      'assets/10s.png',
      '10s'),
  CardModel(
      'ПОЦЕЛУЙ ЛЮБВИ',
      'Перемести 1 единорожка из стопки сброса в свое стойло',
      CardClass.spell,
      'assets/11s.png',
      '11s'),
  CardModel(
      'НЕЧЕСТНАЯ СДЕЛКА',
      'Обменяйся всеми картами с руки с любым другим игроком.',
      CardClass.spell,
      'assets/12s.png',
      '12s'),
  CardModel(
      'НЕЧЕСТНАЯ СДЕЛКА',
      'Обменяйся всеми картами с руки с любым другим игроком.',
      CardClass.spell,
      'assets/13s.png',
      '13s'),
  CardModel(
      'НАГЛЫЙ ГРАБЕЖ ',
      'Посмотри карты на руке другого игрока. Выбери любую карту и возьми ее себе на руку ',
      CardClass.spell,
      'assets/14s.png',
      '14s'),
  CardModel(
      'ОБМЕН ЕДИНОРОЖКАМИ',
      'Перемести 1 единорожка из своего стойла в стойло другого игрока, а затем укради из его стойла 1 единорожка',
      CardClass.spell,
      'assets/15s.png',
      '15s'),
  CardModel(
      'ОБМЕН ЕДИНОРОЖКАМИ',
      'Перемести 1 единорожка из своего стойла в стойло другого игрока, а затем укради из его стойла 1 единорожка',
      CardClass.spell,
      'assets/16s.png',
      '16s'),
  CardModel(
      'ДВА ПО ЦЕНЕ ОДНОГО', 'Принеси в жертву 1 карту, а затем уничтожь 2 карт', CardClass.spell, 'assets/17s.png', '17s'),
  CardModel(
      'ДВА ПО ЦЕНЕ ОДНОГО', 'Принеси в жертву 1 карту, а затем уничтожь 2 карты', CardClass.spell, 'assets/18s.png', '18s'),
  CardModel(
      'МИСТИЧЕСКИЙ ВОДОВОРОТ',
      'Каждый игрок должен сбросить карту. После этого замешай стопку сброса в колоду',
      CardClass.spell,
      'assets/19s.png',
      '19s'),
  CardModel(
      'ВСТРЯСКА',
      'Замешай в колоду эту карту, все карты со своей руки и стопку сброса. После этого возьми 5 карт',
      CardClass.spell,
      'assets/20s.png',
      '20s'),
  CardModel(
      'ЦЕЛЬСЬ! ',
      'Переместил бонус или штраф из стойла любого игрока в стойле любого другого игрока',
      CardClass.spell,
      'assets/21s.png',
      '21s'),
  CardModel(
      'ЦЕЛЬСЬ! ',
      'Переместил бонус или штраф из стойла любого игрока в стойло любого другого игрока',
      CardClass.spell,
      'assets/22s.png',
      '22s'),
  CardModel('ПРИЦЕЛЬНАЯ АТАКА', 'Уничтожь 1 бонус или принеси в жертву 1 штраф',
      CardClass.spell, 'assets/23s.png', '23s'),
  CardModel(
      'ПЕРЕЗАГРУЗКА',
      'Каждый игрок должен принести в жертву все бонусы и штрафы в своем стойле. После этого замешай стопку сброса в колоду',
      CardClass.spell,
      'assets/24s.png',
      '24s'),
  CardModel(
      'ЧИСТАЯ ВЫГОДА',
      'Возьми 3 карты, сбрось 1 карту (необязательно из взятых)',
      CardClass.spell,
      'assets/25s.png',
      '25s'),

  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/1tpru.png',
      '1tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/2tpru.png',
      '2tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/3tpru.png',
      '3tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/4tpru.png',
      '4tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/5tpru.png',
      '5tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/6tpru.png',
      '6tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/7tpru.png',
      '7tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/8tpru.png',
      '8tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/9tpru.png',
      '9tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/10tpru.png',
      '10tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/11tpru.png',
      '11tpru'),
  CardModel(
      'ТПРУ',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя ее эффект',
      CardClass.tpru,
      'assets/12tpru.png',
      '12tpru'),
  CardModel(
      'УБОЙНОЕ ТПРУ!',
      'Сыграй эту карту, когда любой другой игрок пытается сыграть свою карту: ему придётся сбросить эту карту, не применяя её эффект. Эту карту нельзя отменить картой «Тпру»',
      CardClass.tpru,
      'assets/15tpru.png',
      '15tpru'),

  CardModel(
      'АВРАЛЬНЫЙ НАРВАЛ',
      'Когда этот единорожек входит в твое стойло, можешь найти в колоде 1 любой штраф и взять его на руку. Затем перемешай колоду',
      CardClass.unicorn,
      'assets/1u.png',
      '1u'),
  CardModel(
      'МАНЯЩИЙ НАРВАЛ',
      'Когда этот единорожек входит в твое стойло, можешь украсть 1 бонус',
      CardClass.unicorn,
      'assets/2u.png',
      '2u'),
  CardModel(
      'ТОРПЕДНЫЙ НАРВАЛ',
      'Когда этот единорожек входит в твоё стойло, принеси в жертву все штрафы в своём стойле',
      CardClass.unicorn,
      'assets/3u.png',
      '3u'),
  CardModel(
      'ВЕЛИКИЙ НАРВАЛ',
      'Когда этот единорожек входит в твое стойло, можешь найти в колоде любую карту со словом «нарвал» в названии и взять ее на руку. Затем перемешай колоду',
      CardClass.unicorn,
      'assets/4u.png',
      '4u'),
  CardModel(
      'НОСОРОГОРОГ',
      'В начале своего хода ты можешь уничтожить 1 единорожка. После этого твой ход завершается.',
      CardClass.unicorn,
      'assets/5u.png',
      '5u'),
  CardModel(
      'ЛАМАРОГ',
      'Когда этот единорожек входит в твоё стойло, каждый игрок должен сбросить 1 карту ',
      CardClass.unicorn,
      'assets/6u.png',
      '6u'),
  CardModel(
      'ЖИРНОРОГ',
      'Этот единорожек считается за 2 единорожков сразу. Пока он стоит в твоём стойле, ты не можешь играть карты «Тпру»',
      CardClass.unicorn,
      'assets/7u.png',
      '7u'),
  CardModel(
      'ЧЕРНЫЙ БРОНЕРОГ',
      'Если любой другой единорожек в твоем стойле должен быть уничтожен, можешь принести в жертву черного бронерога, чтобы его спасти',
      CardClass.unicorn,
      'assets/8u.png',
      '8u'),
  CardModel(
      'АМЕРИРОГ',
      'Когда этот единорожек входит в твое стойло, можешь случайным образом взять 1 карту с руки другого игрока',
      CardClass.unicorn,
      'assets/9u.png',
      '9u'),
  CardModel(
      'АКУЛОРОГ',
      'Когда этот единорожек входит в твое стойло, можешь принести его в жертву, а затем уничтожить 1 единорожка',
      CardClass.unicorn,
      'assets/10u.png',
      '10u'),
  CardModel(
      'ВОЛШЕБНЫЙ КОТОРОГ',
      'Этого единорожка нельзя уничтожить заклинаниями',
      CardClass.unicorn,
      'assets/11u.png',
      '11u'),
  CardModel(
      'КРУШЕРОГ',
      'Когда этот единорожек входит в твоё стойло, каждый игрок должен принести в жертву 1 единорожка',
      CardClass.unicorn,
      'assets/12u.png',
      '12u'),
  CardModel(
      'ОРАКУЛОРОГ',
      'Когда этот единорожек входит в твое стойло, посмотри 3 верхние карты колоды, 1 возьми на руку, а остальные верни обратно в любом порядке',
      CardClass.unicorn,
      'assets/13u.png',
      '13u'),
  CardModel(
      'ИМПОЗАНТНЫЙ НАРВАЛ',
      'Когда этот единорожек входит в твое стойло, можешь найти в колоде любой бонус и взять его на руку. После этого перемешай колоду',
      CardClass.unicorn,
      'assets/14u.png',
      '14u'),
  CardModel(
      'ЖАДНЫЙ КРЫЛОРОГ',
      'Когда этот единорожек входит в твое стойло, возьми 1 карту. Если жадный крылорог оказывается принесен в жертву или уничтожен, верни его на руку',
      CardClass.unicorn,
      'assets/15u.png',
      '15u'),
  CardModel(
      'БЕСЯЧИЙ КРЫЛОРОГ',
      'Когда этот единорожек входит в твое стойло, ты можешь заставить другого игрока сбросить 1 карту. Если бесячий крылорог оказывается принесен в жертву, или уничтожен, верни его на руку',
      CardClass.unicorn,
      'assets/16u.png',
      '16u'),
  CardModel(
      'ВОЛШЕБНЫЙ КРЫЛОРОГ',
      'Когда этот единорожек входит в твоё стойло, можешь взять на руку 1 заклинание из стопки сброса. Если волшебный крылорог оказывается принесен в жертву или уничтожен, верни его на руку.',
      CardClass.unicorn,
      'assets/17u.png',
      '17u'),
  CardModel(
      'НОЖЕРОГ',
      'Если этот единорожек оказывается принесен в жертву или уничтожен, можешь уничтожить 1 единорожка',
      CardClass.unicorn,
      'assets/18u.png',
      '18u'),
  CardModel(
      'ТЕМНЫЙ АНГЕЛОРОГ',
      'Когда этот единорожек входит в твое стойло, ты можешь принести в жертву 1 единорожка, а затем переместить в свое стойло 1 любого единорожка из стопки сброса',
      CardClass.unicorn,
      'assets/19u.png',
      '19u'),
  CardModel(
      'РУСАЛКОРОГ',
      'Когда этот единорожек входит в твое стойло, заставь 1 другого игрока взять обратно на руку1 карту из его стойла',
      CardClass.unicorn,
      'assets/20u.png',
      '20u'),
  CardModel(
      'ПОЧАТОК РОГ',
      'Когда этот единорожек входит в твое стойло, возьми 2 карты и сбрось 1 карту (необязательно из взятых)',
      CardClass.unicorn,
      'assets/21u.png',
      '21u'),
  CardModel(
      'РЕАКТИВНЫЙ КРЫЛОРОГ',
      'Когда этот единорожек входит в твоё стойло, можешь взять на руку карту «Тпру!» из стопки сброса. Если реактивный крылорог оказывается принесен в жертву или уничтожен, верни его на руку',
      CardClass.unicorn,
      'assets/22u.png',
      '22u'),
  CardModel(
      'БЕНЗОПИЛОРОГ',
      'Когда этот единорожек входит в твое стойло, ты можешь уничтожить 1 бонус или принести в жертву 1 штраф',
      CardClass.unicorn,
      'assets/23u.png',
      '23u'),
  CardModel(
      'ПАФОСНЫЙ КРЫЛОРОГ',
      'Когда этот единорожек входит в твоё стойло, можешь взять на руку 1 единорожка из стопки сброса. Если пафосный крылорог оказывается принесен в жертву или уничтожен, верни его на руку',
      CardClass.unicorn,
      'assets/24u.png',
      '24u'),
  CardModel(
      'ФЕНИКСОРОГ',
      'Если этот единорожек должен быть принесён в жертву или уничтожен, можешь сбросить 1 карту, чтобы его спасти',
      CardClass.unicorn,
      'assets/25u.png',
      '25u'),
];

class Deck {

  // Метод для преобразования колоды в список Map для Firestore
  static List<Map<String, dynamic>> deckToMap(List<CardModel> deck) {
    return deck.map((card) => card.toMap()).toList();
  }

// update deck
  static Future<void> updateDeck(String roomName, List<CardModel> cards) async {
    List<Map<String, dynamic>> cardData =
        cards.map((card) => card.toMap()).toList();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      'deck': cardData,
    });
  }

  //update player deck
  static Future<void> updatePlayerDeck(String roomName, List<CardModel> cards, String typeDeck, String playerID) async {
    List<Map<String, dynamic>> cardData =
    cards.map((card) => card.toMap()).toList();

    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .update({
      typeDeck : cardData,
    });
  }

  // get deck
  static Future<List<CardModel>?> getDeck(String roomName) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('deck')) {
        List<dynamic> cardsData = data['deck'];

        List<CardModel> cards =
            cardsData.map((cardData) => CardModel.fromMap(cardData)).toList();
        return cards;
      }
    }
    return null; // Если колода не найдена
  }
 //get player deck fines/effects/bonuses..
  static Future<List<CardModel>?> getPlayerDeck(String roomName, String typeDeck, String playerID) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey(typeDeck)) {
        List<dynamic> cardsData = data[typeDeck];

        List<CardModel> cards =
        cardsData.map((cardData) => CardModel.fromMap(cardData)).toList();
        return cards;
      }
    }
    return null; // Если колода не найдена
  }

//update add new card GameState
  static Future<void> updateWithNewCardGameState(
      String roomName, CardModel newCard, String typeDeck) async {
    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .update({
      typeDeck: FieldValue.arrayUnion([newCard.toMap()]),
    });
  }

  //update add new card PlayerState
  static Future<void> updateWithNewCardPlayerState(String roomName,
      CardModel newCard, String typeDeck, String playerID) async {
    await FirebaseFirestore.instance
        .collection(roomName)
        .doc('room')
        .collection('GameState')
        .doc('state')
        .collection('playersState')
        .doc(playerID)
        .update({
      typeDeck: FieldValue.arrayUnion([newCard.toMap()]),
    });
  }
}

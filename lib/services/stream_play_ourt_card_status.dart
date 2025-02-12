// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:unstable_unicorns/provider/remember_card.dart';
//
// class StreamPlayOutCardStatus extends StatelessWidget {
//   String playersRoom;
//
//   StreamPlayOutCardStatus({
//     super.key,
//     required this.playersRoom,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection(playersRoom)
//             .doc('room')
//             .collection('GameCardStatus')
//             .doc('state')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             print('Error: ${snapshot.error}');
//             return const SizedBox.shrink();
//           } else if (!snapshot.hasData ||
//               snapshot.data == null ||
//               !snapshot.data!.exists) {
//             return const SizedBox.shrink();
//           }
//           final data = snapshot.data?.data() as Map<String, dynamic>;
//           String? gameCardStatus = data['gameCardStatus'];
//           print('gameCardStatus $gameCardStatus');
//
//           // WidgetsBinding.instance.addPostFrameCallback((_) {
//            Provider.of<GamePlayOutCardStatus>(context, listen:false)
//                 .updateCardEffects(gameCardStatus!);
//           // });
//           return const SizedBox.shrink();
//         });
//   }
// }
//

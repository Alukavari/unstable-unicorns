import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import 'package:unstable_unicorns/provider/game_play_out_card_status_provider.dart';

import '../provider/game_data_provider.dart';


class StreamActCount extends StatelessWidget {
  String playersRoom;

  StreamActCount({
    super.key,
    required this.playersRoom,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(playersRoom)
            .doc('room')
            .collection('action')
            .doc('state')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const SizedBox.shrink();
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const SizedBox.shrink();
          }
          final data =
          snapshot.data?.data() as Map<String, dynamic>;

          int actCount = data['actCount'] ?? 0;
          print('actCount $actCount');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<GameDataProvider>(context,
                listen: false)
                .updateActCount(actCount);
          });
          return const SizedBox.shrink();
        });
  }
}
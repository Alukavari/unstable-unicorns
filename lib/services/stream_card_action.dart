import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';


class StreamCardAction extends StatelessWidget {
  String playersRoom;

  StreamCardAction({
    super.key,
    required this.playersRoom,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(playersRoom)
            .doc('room')
            .collection('cardAction')
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

          int cardAction = data['cardAction'] ?? 0;
          print('cardAction $cardAction');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ProgressCheckProvider>(context,
                listen: false)
                .updateCheck(cardAction);
          });
          return const SizedBox.shrink();
        });
  }
}


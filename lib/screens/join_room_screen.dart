import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/screens/create_room_screen.dart';
import 'package:unstable_unicorns/screens/game_board_screen.dart';
import 'package:unstable_unicorns/screens/lobby.dart';
import 'package:unstable_unicorns/services/responsive.dart';
import 'package:unstable_unicorns/widgets/custom_button.dart';
import 'package:unstable_unicorns/widgets/custom_text.dart';

import '../const/colors.dart';
import '../const/const.dart';
import '../services/snack_bar.dart';

class JoinRoom extends StatelessWidget {
  final String email;
  final String userNickname;

  JoinRoom({super.key, required this.email, required this.userNickname});

  List<Map<String, dynamic>> rooms = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _addUser(
      BuildContext context, String roomName, String deleteNameRoom) async {
    final playerRef = firestore.collection(roomName);
    final QuerySnapshot snapshot = await playerRef.get();
    int playerCount = snapshot.docs.length;
    final roomSnapShot = await playerRef.doc('player1').get();

    // check on same user in this room
    if (roomSnapShot. exists && roomSnapShot.data()?['email'] == email){
        SnackBarService.showSnackBar(
            context, 'You are already in this room!', true);
        return;
      }
    else if (playerCount < 2) {
      try {
        CollectionReference playersRoom =
            FirebaseFirestore.instance.collection(roomName);
        await playersRoom.doc('player2').set({
          'playerID': email.hashCode,
          'email': email,
          'user_nickname': userNickname,
        });

        playerCount++;

        if (playerCount == 2) {
          await firestore.collection('user room').doc(deleteNameRoom).delete();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameBoardScreen(
                playersRoom: roomName,
                userNickname: userNickname,
              ),
            ),
          );
        }
      } catch (e) {
        SnackBarService.showSnackBar(
          context,
          'Error $e',
          true,
        );
      }
    } else if (playerCount >= 3) {
      await firestore.collection('user room').doc(deleteNameRoom).delete();
      SnackBarService.showSnackBar(
          context,
          'There are already 2 players, select another room or create your own',
          true);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Lobby(email: email)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(text: 'Available rooms', fontSize: 70),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user room')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: textBoldUnderline);
                    } else if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      rooms = snapshot.data?.docs.map((doc) {
                            return {
                              'user_nickname':
                                  doc['user_nickname'] ?? 'Unknown User',
                              'name_room': doc['name_room'] ?? 'Unnamed Room',
                              'email': doc['email'] ?? 'Unnamed Email',
                            };
                          }).toList() ??
                          [];
                      return Responsive(
                        child: Expanded(
                          child: Column(
                            children: rooms.map<Widget>((room) {
                              return ListTile(
                                title: Text(
                                  room['user_nickname'] ?? [],
                                  style: textBold,
                                ),
                                subtitle: Expanded(
                                  child: ElevatedButton(
                                      onPressed: () => _addUser(
                                          context,
                                          '${room['user_nickname']}_${room['name_room']}',
                                          room['email']),
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: bgColor,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      child: Text('${room['name_room']}',
                                          style: textBold)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 60),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: CustomButton(
                      onPressed: Lobby(email: email), title: 'Exit to Lobby'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

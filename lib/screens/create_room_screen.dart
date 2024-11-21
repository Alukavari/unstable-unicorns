import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/const.dart';
import 'package:unstable_unicorns/screens/game_board_screen.dart';
import 'package:unstable_unicorns/services/responsive.dart';
import 'package:unstable_unicorns/widgets/custom_text.dart';
import 'package:unstable_unicorns/widgets/custom_textfield.dart';

import '../const/colors.dart';
import '../services/snack_bar.dart';

class CreateRoom extends StatelessWidget {
  final String email;
  final String userNickname;

  CreateRoom({super.key, required this.email, required this.userNickname});

  final TextEditingController _nameRoomController = TextEditingController();
  final formKey = GlobalKey<FormState>();


  Future<void> _roomList(BuildContext context) async {
    String nameRoom = _nameRoomController.text;

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      CollectionReference _firestore =
          FirebaseFirestore.instance.collection('user room');
      await _firestore.doc(email).set({
        'email': email,
        'user_nickname': userNickname,
        'name_room': nameRoom,
      });

      // create room for 2 players
      final roomRef = FirebaseFirestore.instance
          .collection('${userNickname}_$nameRoom')
          .doc('player1');
      await roomRef.set({
        'playerID': email.hashCode,
        'email': email,
        'user_nickname': userNickname,
        'name_room': nameRoom,
      });

    } on FirebaseAuthException catch (e) {
      print(e.code);

      SnackBarService.showSnackBar(
        context,
        'Error $e',
        true,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameBoardScreen(
            playersRoom: '${userNickname}_$nameRoom',
            userNickname: userNickname),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        child: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomText(text: 'Create Room', fontSize: 70),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameRoomController,
                      hintText: 'Enter the room name',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () => _roomList(context),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: bgColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text('Create', style: textBold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

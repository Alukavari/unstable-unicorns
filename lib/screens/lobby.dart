import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/const/colors.dart';
import 'package:unstable_unicorns/screens/create_room_screen.dart';
import 'package:unstable_unicorns/screens/join_room_screen.dart';
import 'package:unstable_unicorns/services/responsive.dart';
import 'package:unstable_unicorns/widgets/custom_button.dart';
import '../const/const.dart';
import '../models/game.dart';
import '../services/snack_bar.dart';

class Lobby extends StatelessWidget {
  final String email;
  final String userCredential;

  // Lobby({super.key, required this.userCredential, required this.email});
  Lobby({required this.email, required this.userCredential});

  late String userNickname;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: FutureBuilder(
          future: Game.getUserNicknameByEmail(userCredential),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: textBoldUnderline);
            } else {
              userNickname = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome Lobby, $userNickname !', textAlign: TextAlign.center, style: textBold),
                  const SizedBox(height: 20),
                  Text('You can Create a Room or Join an existing one.',
                      style: textBold, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Responsive(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Responsive(
                        Expanded(
                          child: CustomButton(
                              onPressed: CreateRoom(userCredential: userCredential, userNickname: userNickname, email: email,),
                              title: 'Create Room'),
                        ),
                        const SizedBox(width: 5),
                        // Responsive(
                        Expanded(
                          child: CustomButton(
                              // onPressed: JoinRoom(email: email, userNickname: userNickname,),
                              onPressed: JoinRoom(userCredential: userCredential, userNickname: userNickname, email: email,),
                              title: 'Join Room'),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/signIn'),
                    child: Text('Exit', style: textBoldUnderline),
                  ),
                ],
              );
            }
          },
        ),
            ),
      ),
    );
  }
}

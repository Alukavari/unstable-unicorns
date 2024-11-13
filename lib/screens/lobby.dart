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
import '../services/snack_bar.dart';

class Lobby extends StatelessWidget {
  final String email;

  Lobby({super.key, required this.email});

  late String userNickname;


  Future<String?> getUserNicknameByEmail(String email) async {
    var userNickname = '';
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await users.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      userNickname = querySnapshot.docs.first['userNickname'];
    } else {
      SnackBarService.showSnackBar(
          userNickname as BuildContext, 'Nickname not found...', false);
    }
    return userNickname;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: FutureBuilder(
          future: getUserNicknameByEmail(email),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Responsive(
                        child: Expanded(
                          child: CustomButton(
                              onPressed: CreateRoom(email: email, userNickname: userNickname,),
                              title: 'Create Room'),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Responsive(
                        child: Expanded(
                          child: CustomButton(
                              onPressed: JoinRoom(email: email, userNickname: userNickname,),
                              title: 'Join Room'),
                        ),
                      ),
                    ],
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

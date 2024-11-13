import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/screens/signIn_screen.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';

import '../screens/lobby.dart';

class FirebaseStream extends StatelessWidget {
  final String email;

  const FirebaseStream({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Something wrong..')));
        } else if (snapshot.hasData) {
          SnackBarService.showSnackBar(
            context,
            'Welcome to the unstoppable unicorns',
            false
          );
            return Lobby(email: email);
          } else{
            return const SignInScreen();
        }
      },
    );
  }
}

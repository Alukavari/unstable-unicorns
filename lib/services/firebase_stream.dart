import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/screens/signIn_screen.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import '../screens/lobby.dart';

class FirebaseStream extends StatelessWidget {
  final String email;
  final String userCredential;

  const FirebaseStream({super.key, required this.email, required this.userCredential});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Something wrong..')));
        } else if (snapshot.hasData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    SnackBarService.showSnackBar(
            context,
            'Welcome to the unstoppable unicorns',
            false
          );
    });
    // return Lobby(email: email);
            return Lobby(userCredential: userCredential, email: email,);
          } else{
            return const SignInScreen();
        }
      },
    );
  }
}

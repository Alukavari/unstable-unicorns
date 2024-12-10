import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/colors.dart';
import 'package:unstable_unicorns/firebase_options.dart';
import 'package:unstable_unicorns/screens/signIn_screen.dart';
import 'package:unstable_unicorns/screens/signUp_screen.dart';
import 'package:unstable_unicorns/services/current_player_provider.dart';
import 'package:unstable_unicorns/services/game_data_provider.dart';

import 'models/game_state.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentPlayerState()),
        ChangeNotifierProvider(create: (context) => GameDataProvider()),
  ],
          child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bgColor),
            routes: {
              '/signUp': (context) => const SignUpScreen(),
              '/signIn': (context) => const SignInScreen(),
            },
          initialRoute: '/',
          home: const SignInScreen(),
    );
  }
}


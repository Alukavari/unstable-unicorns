import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/colors.dart';
import 'package:unstable_unicorns/firebase_options.dart';
import 'package:unstable_unicorns/provider/check_progress_provider.dart';
import 'package:unstable_unicorns/provider/game_play_out_card_status_provider.dart';
import 'package:unstable_unicorns/screens/signIn_screen.dart';
import 'package:unstable_unicorns/screens/signUp_screen.dart';
import 'package:unstable_unicorns/provider/current_player_provider.dart';
import 'package:unstable_unicorns/provider/discard_card_provider.dart';
import 'package:unstable_unicorns/provider/play_out_card_provider.dart';
import 'package:unstable_unicorns/provider/game_data_provider.dart';




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentPlayerState()),
        ChangeNotifierProvider(create: (context) => GameDataProvider()),
        ChangeNotifierProvider(create: (context) => PlayOutCardProvider()),
        ChangeNotifierProvider(create: (context) => DiscardCardProvider()),
        ChangeNotifierProvider(create: (context) => ProgressCheckProvider()),
        ChangeNotifierProvider(create: (context) => GamePlayOutCardStatus()),
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


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unstable_unicorns/const/colors.dart';
import 'package:unstable_unicorns/firebase_options.dart';
import 'package:unstable_unicorns/screens/signIn_screen.dart';
import 'package:unstable_unicorns/screens/signUp_screen.dart';
import 'package:unstable_unicorns/widgets/room_data_provider.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomDataProvider(),
      child: MaterialApp(
            theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bgColor),
            routes: {
              '/signUp': (context) => const SignUpScreen(),
              '/signIn': (context) => const SignInScreen(),
            },
          initialRoute: '/',
          home: const SignInScreen(),
          ),
    );
  }
}


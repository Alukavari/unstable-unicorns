import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/services/responsive.dart';
import 'package:unstable_unicorns/widgets/custom_text.dart';
import '../const/colors.dart';
import '../const/const.dart';
import '../services/snack_bar.dart';
import 'lobby.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscureText = true;



   Future<void>signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'userID': userCredential.user!.uid,
        'userNickname': _nicknameController.text.trim(),
        'email': _emailController.text.trim(),
      });

    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'email-already-in-use') {
        SnackBarService.showSnackBar(
          context,
          'The account already exists for that email',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(context, 'Unknown error', true);
      }
    }
    SnackBarService.showSnackBar(
        context, 'Welcome to the unstoppable unicorns!', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Lobby(email: _emailController.text.trim()),
      ),
    );
  }

  void togglePasswordView() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const CustomText(text: 'Sign Un', fontSize: 70),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Please enter correct email'
                            : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your email',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nicknameController,
                    validator: (nickname) =>
                        nickname!.isEmpty ? 'Please enter nickname' : null,
                    decoration: const InputDecoration(
                      hintText: 'Enter your nickname',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: obscureText,
                    validator: (value) => value != null && value.length < 6
                        ? 'Password must be longer than 6'
                        : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter your password',
                        suffix: InkWell(
                          onTap: togglePasswordView,
                          child: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                        )),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: signUp,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: bgColor,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: Text('Sign Up', style: textBold)),
                      ),
                      const SizedBox(width: 5),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/signIn'),
                        child: Text('Return to Sign In', style: textBoldUnderline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

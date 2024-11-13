import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unstable_unicorns/services/snack_bar.dart';
import '../const/colors.dart';
import '../const/const.dart';
import '../services/firebase_stream.dart';
import '../services/responsive.dart';
import '../widgets/custom_text.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscureText = true;

  late final FocusNode passwordFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode buttonFocusNode;

  @override
  void initState() {
    passwordFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    buttonFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    emailFocusNode.dispose();
    buttonFocusNode.dispose();
    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future<void> singIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);

      if (e.code == 'invalid-credential') {
        SnackBarService.showSnackBar(
          context,
          'Wrong password or email, try again',
          true,
        );
        return;
      }
    }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FirebaseStream(email: _emailController.text.trim()),
        ),
      );
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
                  const CustomText(text: 'Sign In', fontSize: 70),
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
                            focusNode: buttonFocusNode,
                            onPressed: singIn,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: bgColor,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: Text('Sign In', style: textBold)),
                      ),
                      const SizedBox(width: 5),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/signUp'),
                        child: Text('Sign Up', style: textBoldUnderline),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

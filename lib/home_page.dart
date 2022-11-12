import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:osake/sake_list_page.dart';

import 'sign_in_page.dart';
import 'sign_up_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _onSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  void _onSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appNameText = Text(
      'osake',
      style: Theme.of(
        context,
      ).textTheme.displayLarge,
    );
    final signUpButton = ElevatedButton(
      onPressed: _onSignUp,
      child: const Text('Sign up'),
    );
    final signInButton = TextButton(
      onPressed: _onSignIn,
      child: const Text('Sign in'),
    );

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return const SakeListPage();
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    appNameText,
                    signUpButton,
                    signInButton,
                  ],
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

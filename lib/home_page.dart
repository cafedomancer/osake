import 'package:flutter/material.dart';

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'osake',
                style: Theme.of(
                  context,
                ).textTheme.headline3,
              ),
              ElevatedButton(
                onPressed: _onSignUp,
                child: const Text('Sign up'),
              ),
              TextButton(
                onPressed: _onSignIn,
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

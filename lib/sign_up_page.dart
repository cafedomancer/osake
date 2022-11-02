import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'sake_list_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set(<String, Timestamp>{
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now()
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SakeListPage(),
      ),
    );
  }

  void _onHome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email *',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter some text' : null,
    );
    final passwordField = TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password *',
      ),
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter some text' : null,
    );
    final signUpButton = ElevatedButton(
      onPressed: _onSignUp,
      child: const Text('Sign up'),
    );
    final homeButton = TextButton(
      onPressed: _onHome,
      child: const Text('Home'),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                emailField,
                passwordField,
                signUpButton,
                homeButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

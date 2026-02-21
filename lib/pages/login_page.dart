import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Username',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'E-mail',
            ),
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
          ),
        ],
      ),
    );
  }
}
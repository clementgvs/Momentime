import 'package:flutter/material.dart';
import 'package:momentime/account_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  String username = "";
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return isLogin ? Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: 0,
            height: 100,
          ),
          TextField(
            onChanged: (value) => setState(() => email=value),
            decoration: InputDecoration(
              hintText: 'E-mail',
            ),
          ),
          TextField(
            onChanged: (value) => setState(() => password=value),
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
          ),
          TextButton(
            onPressed: () => AccountManager().signIn(email, password),
            child: Text("Login")
          ),
          TextButton(
            onPressed: () => setState(() {
              isLogin=!isLogin;
            }),
            child: Text("Créer un compte")
          ),
        ],
      ),
    )
    :
    Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: 0,
            height: 100,
          ),
          TextField(
            onChanged: (value) => setState(() => username=value),
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
            onChanged: (value) => setState(() => email=value),
            decoration: InputDecoration(
              hintText: 'Confirm E-mail',
            ),
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
          ),
          TextField(
            onChanged: (value) => setState(() => password=value),
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm password',
            ),
          ),
          TextButton(
            onPressed: () => AccountManager().signUp(email=email, password=password, username=username),
            child: Text("Register")
          ),
          TextButton(
            onPressed: () => setState(() {
              isLogin=!isLogin;
            }),
            child: Text("Déjà un compte ? Se connecter !")
          ),
        ],
      ),
    );
  }
}
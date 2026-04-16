import 'package:flutter/material.dart';
import 'package:momentime/backend/account_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  String username = "";
  String email = "";
  String emailConfirm = "";
  String password = "";
  String passwordConfirm = "";
  bool isRegisterUsernameTaken = false;

  @override
  Widget build(BuildContext context) {
    return isLogin ? Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(40),
        child: Column(
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
                onPressed: () {
                  if(email.isNotEmpty && password.isNotEmpty){
                    AccountManager().signIn(email, password);
                  }
                },
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
      ),
    )
    :
    Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(40),
        child: Column(
          children: [
            SizedBox(
              width: 0,
              height: 100,
            ),
            TextField(
              onChanged: (value) async {
                isRegisterUsernameTaken = await AccountManager().isUsernameTaken(value);
                setState(()  => username=value);
              },
              decoration: InputDecoration(
                hintText: 'Username',
              ),
            ),
            if(isRegisterUsernameTaken)
              Text("Username déjà pris"),
            TextField(
              onChanged: (value) => setState(() => email=value),
              decoration: InputDecoration(
                hintText: 'E-mail',
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => emailConfirm=value),
              decoration: InputDecoration(
                hintText: 'Confirm E-mail',
              ),
            ),
            if(email!=emailConfirm && email.isNotEmpty && emailConfirm.isNotEmpty)
              Text("Les e-mails ne correspondent pas."),
            TextField(
              onChanged: (value) => setState(() => password=value),
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => passwordConfirm=value),
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm password',
              ),
            ),
            if(password!=passwordConfirm && password.isNotEmpty && passwordConfirm.isNotEmpty)
              Text("Les mots de passe correspondent pas."),
            TextButton(
              onPressed: () {
                if(password==passwordConfirm
                    && password.isNotEmpty
                    && passwordConfirm.isNotEmpty
                    && !isRegisterUsernameTaken) {
                  AccountManager().signUp(email=email, password=password, username=username);
                }
              },
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
      ),
    );
  }
}
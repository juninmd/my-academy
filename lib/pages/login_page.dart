import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../constants.dart';
import 'menus_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? event) {
      setState(() {
        _user = event;
        if (_user != null) {
          FireBaseUser = _user!;
          // Usuário já está logado, redirecione para MenusPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MenusPage(user: _user!)),
          );
          return;
        }
      });
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final googleSignInAccount =
          await googleSignIn.signIn();
      final googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final authResult =
          await _auth.signInWithCredential(credential);

      print("Signed in: ${authResult.user!.displayName}");

      FireBaseUser = authResult.user!;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenusPage(user: _user!)),
      );
    } catch (error) {
      print("Error signing in with Google: $error");
      const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        content: Text(
            'Erro ao fazer login com o Google. Por favor, tente novamente.!'),
        duration: Duration(seconds: 5), // Optional: Set a custom duration
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget _googleSignInButton() {
    return Container(
      margin: EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          text: "Entrar com Google",
          onPressed: _handleSignIn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ia/a.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Faça login para continuar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 20),
                  _googleSignInButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

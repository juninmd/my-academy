import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/my_academy/user_api.dart';
import 'menus_page.dart';

final loginPageStoreProvider =
    ChangeNotifierProvider((ref) => LoginPageStore());

class LoginPage extends HookConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(loginPageStoreProvider);
    final auth = FirebaseAuth.instance;

    void redirect(BuildContext context) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenusPage()),
      );
    }

    Future<User?> setUser() async {
      try {
        // To change it after initialization, use `setPersistence()`:
        await auth.setPersistence(Persistence.LOCAL);

        await Firebase.initializeApp();
        if (FireBaseUser == null) {
          return null;
        }
        await getUserById(FireBaseUser!.uid);
        return FireBaseUser;
      } catch (err) {
        final user = Users(
            id: FireBaseUser!.uid,
            photoUrl: FireBaseUser!.photoURL!,
            email: FireBaseUser!.email!,
            name: FireBaseUser!.displayName!);

        await postUser(user);
        return FireBaseUser;
      }
    }

    useEffect(() {
      setUser();
      return null;
    }, [FireBaseUser]);

    auth.authStateChanges().listen((User? event) async {
      FireBaseUser = event;
      await setUser();
      if (FireBaseUser != null) {
        final idTokenResult = await FireBaseUser!.getIdTokenResult();
        final token = idTokenResult.token;
        print('token');
        print(token);
      }
    });

    Future<void> _handleSignIn(BuildContext context) async {
      try {
        if (FireBaseUser != null) {
          return redirect(context);
        }

        final googleSignInAccount = await store.googleSignIn.signIn();
        final googleSignInAuthentication =
            await googleSignInAccount?.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication!.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final authResult = await store.auth.signInWithCredential(credential);

        FireBaseUser = authResult.user;
        return redirect(context);
      } catch (error) {
        print("Error signing in with Google: $error");
        var snackBar = SnackBar(
          content: Text(
              'Erro ao fazer login com o Google. Por favor, tente novamente.'),
          duration: Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    Widget _buildGoogleSignInButton(BuildContext context) => Container(
          margin: const EdgeInsets.all(16),
          child: SizedBox(
            height: 40,
            child: SignInButton(
              Buttons.google,
              text: "Entrar com Google",
              onPressed: () => _handleSignIn(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Background image with blur effect
          _buildBackgroundImage(context),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'My Academy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .black87, // Adjust based on background contrast
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildGoogleSignInButton(context),
                    Card(
                      color: Colors.deepPurple,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.info,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Realize os exercícios com supervisão de um profissional',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ia/a.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }

// Login logic remains the same (refer to original code)
}

class LoginPageStore extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
}

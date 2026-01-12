import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/my_academy/user_api.dart';
import '../theme/app_theme.dart';
import 'menus_page.dart';

final loginPageStoreProvider = ChangeNotifierProvider(
  (ref) => LoginPageStore(),
);

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoginPageStore store = ref.watch(loginPageStoreProvider);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final fadeAnimation = useAnimation(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
    final slideAnimation = useMemoized(
      () =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOutCubic,
        ),
      ),
      [animationController],
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    void redirect(BuildContext context) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MenusPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }

    Future<User?> setUser() async {
      try {
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
          name: FireBaseUser!.displayName!,
        );

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
        debugPrint('Token: $token');
      }
    });

    Future<void> handleSignIn(BuildContext context) async {
      try {
        if (FireBaseUser != null) {
          return redirect(context);
        }

        final googleSignInAccount = await store.googleSignIn.signIn();
        if (googleSignInAccount == null) {
          throw Exception('Google Sign In was cancelled');
        }
        final googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication!.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final authResult = await store.auth.signInWithCredential(credential);

        FireBaseUser = authResult.user;
        return redirect(context);
      } catch (error) {
        debugPrint("Error signing in with Google: $error");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Erro ao fazer login com o Google. Por favor, tente novamente.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F0F1A),
                ],
              ),
            ),
          ),
          // Background image with blur
          Positioned.fill(
            child: Image.asset(
              'assets/images/ia/a.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: AppTheme.backgroundDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(fadeAnimation),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo/Title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.accentGradient,
                            boxShadow: AppTheme.glowShadow,
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'My Academy',
                          style: AppTheme.headingLarge.copyWith(
                            fontSize: 36,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seu treino na palma da mão',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Glassmorphism card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: GlassDecoration(
                            borderRadius: AppTheme.radiusXLarge,
                          ),
                          child: Column(
                            children: [
                              Text('Bem-vindo!', style: AppTheme.headingSmall),
                              const SizedBox(height: 8),
                              Text(
                                'Entre com sua conta Google para continuar',
                                style: AppTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Custom styled sign-in button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => handleSignIn(context),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMedium,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://www.google.com/favicon.ico',
                                          height: 24,
                                          width: 24,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.g_mobiledata,
                                            size: 24,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Entrar com Google',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Info card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                            border: Border.all(
                              color: AppTheme.info.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppTheme.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Realize os exercícios com supervisão de um profissional',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPageStore extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
}

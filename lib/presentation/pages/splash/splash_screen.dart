import 'package:flutter/material.dart';
import 'package:dompetku/presentation/pages/auth/pilihan_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

//animasi logo dari atas
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _logoOffset = -200.0;
  double _logoOpacity = 0.0;


  static const Duration _logoBounceDuration = Duration(milliseconds: 1200);
  // Total durasi sebelum navigasi
  static const Duration _navigationDelay = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _logoOffset = 0.0;
        _logoOpacity = 1.0;
      });
    });


    Future.delayed(_navigationDelay, () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PilihanLogin(),
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF2),
      body: Center(
        child: AnimatedOpacity(
          opacity: _logoOpacity,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: _logoBounceDuration,
            curve: Curves.bounceOut,
            transform: Matrix4.translationValues(0.0, _logoOffset, 0.0),
            child: Hero(
              tag: "app_logo",
              child: Image.asset(
                "assets/images/logo.png",
                width: 400,
                height: 400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
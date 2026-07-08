import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:budlee_app/config/user/login_and_register/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

import 'layouts/home_layout/home_page.dart';
import 'onborading.dart';

class SplashScreen extends StatelessWidget {
  final String? uId;
  final bool onBoarding;

  const SplashScreen({super.key, required this.uId, required this.onBoarding});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: LottieBuilder.asset(
        'assets/animations/Social-Media-Influencer.json',
      ),
      splashTransition: SplashTransition.fadeTransition,
      duration: 4000,
      nextScreen: uId!.isNotEmpty
          ? HomeScreen()
          : onBoarding
          ? OnBoarding()
          : Login(),
      backgroundColor: HexColor('86bade'),
      splashIconSize: 800,
    );
  }
}

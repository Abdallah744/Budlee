// ignore_for_file: unused_import

import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
import 'package:budlee_app/utils/shared/network/remote/dio_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:budlee_app/config/cubit/app_cubit/app_bloc.dart';
import 'package:budlee_app/config/cubit/app_cubit/app_event.dart';
import 'package:budlee_app/config/cubit/bloc_observe.dart';
import 'package:budlee_app/config/cubit/login/login_bloc.dart';
import 'package:budlee_app/core/constants/constants.dart';
import 'package:budlee_app/core/styles/themes.dart';
import 'package:budlee_app/modules/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDVEKChVkkZaaRKjBhYdhLhPYVrxem8tws",
        authDomain: "my-mobile-apps-div.firebaseapp.com",
        projectId: "my-mobile-apps-div",
        storageBucket: "my-mobile-apps-div.firebasestorage.app",
        messagingSenderId: "164683215851",
        appId: "1:164683215851:web:a8d63e95b90f4ab817dfae",
        measurementId: "G-136TQEMZP5",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await Supabase.initialize(
    url: 'https://updocizudnatmwzyfcne.supabase.co',
    publishableKey: 'sb_publishable_K6vHM1dGaos_G_W5lMkEzA_D7NGvS_4',
  );

  DioHelper.init();

  Bloc.observer = MyBlocObserver();
  await CashHelper.init();
  bool? onBoarding = CashHelper.get(key: 'onBoarding');
  uId = CashHelper.get(key: 'uId') ?? '';
  runApp(MyApp(onBoarding: onBoarding ?? true, uId: uId));
}

class MyApp extends StatelessWidget {
  final bool onBoarding;
  final String? uId;
  const MyApp({super.key, required this.onBoarding, required this.uId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(
          create: (context) => AppBloc()
            ..add(AppGetUserDataEvent(uId))
            ..add(AppGetPostsEvent())
            ..add(AppGetUsersEvent())
            ..add(AppGetFriendsEvent()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: SplashScreen(uId: uId, onBoarding: onBoarding),
      ),
    );
  }
}

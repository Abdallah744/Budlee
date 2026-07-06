import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/modules/layouts/home_layout/home_page.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/cubit/app_cubit/app_cubit.dart';
import 'config/cubit/bloc_observe.dart';
import 'config/cubit/login/login_cubit.dart';
import 'config/user/login_and_register/login_screen.dart';
import 'core/constants/constants.dart';
import 'core/styles/themes.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
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

  var token = await FirebaseMessaging.instance.getToken();
  print("Token: $token");
  FirebaseMessaging.onMessage.listen((event) {
    print(event.data.toString());
    print('onMessage: $event');
    showToast(
      text: 'onMessage: ${event.data.toString()}',
      state: ToastStates.SUCCESS,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print(event.data.toString());
    print('onMessageOpenedApp: $event');
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Bloc.observer = MyBlocObserver();
  await CashHelper.init();
  bool? onBoarding = CashHelper.get(key: 'onBoarding');
  uId = CashHelper.get(key: 'uId') ?? '';
  runApp(MyApp(onBoarding: onBoarding ?? false, uId: uId));
}

class MyApp extends StatelessWidget {
  final bool onBoarding;
  final String? uId;
  const MyApp({required this.onBoarding, required this.uId});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(
          create: (context) => AppCubit()
            ..getUserData(uId!)
            ..getPosts()
            ..getUsers(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: uId!.isNotEmpty ? HomeScreen() : Login(),
      ),
    );
  }
}

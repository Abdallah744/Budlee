import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/cubit/app_cubit/app_cubit.dart';
import 'config/cubit/bloc_observe.dart';
import 'config/cubit/login/login_cubit.dart';
import 'core/constants/constants.dart';
import 'core/styles/themes.dart';
import 'modules/splash_screen.dart';

// Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Android Notification Channel
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

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

  // Initialize Local Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap here if needed
      print('Notification tapped: ${response.payload}');
    },
  );

  // Create Android Notification Channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Request Notification Permissions
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Handle Foreground Messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    bool isEnabled = CashHelper.get(key: 'isNotificationEnabled') ?? true;
    if (isEnabled) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    }
  });

  // Handle opening from Terminated/Background state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message opened app: ${message.data}');
    // You can navigate here based on message.data
  });

  RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    print('Initial message: ${initialMessage.data}');
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(
          create: (context) => AppCubit()
            ..getUserData(uId)
            ..getPosts()
            ..getUsers()
            ..getFriends(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: SplashScreen(uId: uId, onBoarding: onBoarding),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/firebase_options.dart';
import 'package:tiffinwala/screens/auth.dart';
import 'package:tiffinwala/screens/menu.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: Tiffinwala(token: token)));
}

final authProvider = StateProvider<bool>((ref) => false);

bool isTokenValid(String? token) {
  if (token == null) return false;
  if (token.isNotEmpty && JwtDecoder.isExpired(token) == false) {
    return true;
  }
  return false;
}

class Tiffinwala extends ConsumerStatefulWidget {
  final String? token;
  const Tiffinwala({super.key, required this.token});

  @override
  ConsumerState<Tiffinwala> createState() => _TiffinwalaState();
}

class _TiffinwalaState extends ConsumerState<Tiffinwala> {
  late final FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();

    initializeLocalNotifications();
    registerNotification();

    bool valid = isTokenValid(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).state = valid;
    });
  }

  void initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
          ),
        );
  }

  void registerNotification() async {
    _messaging = FirebaseMessaging.instance;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _messaging.subscribeToTopic("all_users");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });    
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(authProvider);

    return shadcn.ShadcnApp(
      title: 'Tiffinwala',
      debugShowCheckedModeBanner: false,
      theme: shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.darkNeutral(),
        radius: 0.5,
      ),
      home: isAuth ? const Menu() : const Auth(),
    );
  }
}

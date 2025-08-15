import 'dart:async';
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

final authProvider = StateProvider<bool>((ref) => false);

bool isTokenValid(String? token) {
  if (token == null) return false;
  if (token.isNotEmpty && JwtDecoder.isExpired(token) == false) {
    return true;
  }
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const Tiffinwala()));
}

class Tiffinwala extends ConsumerStatefulWidget {
  final String? token = null; // original retained
  const Tiffinwala({super.key});

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
  }

  void initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
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
    return shadcn.ShadcnApp(
      title: 'Tiffinwala',
      debugShowCheckedModeBanner: false,
      theme: shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.darkNeutral(),
        radius: 0.5,
      ),
      home: const SplashScreen(),
    );
  }
}
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _checkedToken = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCirc),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      bool valid = isTokenValid(token);

      if (mounted) {
        ref.read(authProvider.notifier).state = valid;
        setState(() {
          _checkedToken = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This ensures ref.listen is only triggered once (after token is checked)
    if (_checkedToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final isLoggedIn = ref.read(authProvider);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isLoggedIn ? const Menu() : const Auth(),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: ClipOval(
            child: Image.asset("assets/logo.png", width: 120, height: 120),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/screens/auth.dart';
import 'package:tiffinwala/screens/menu.dart';
import 'package:tiffinwala/screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  runApp(ProviderScope(child: Tiffinwala(token: token)));
}

bool isTokenValid(String? token) {
  if (token == null) return false;

  if (token.isNotEmpty && JwtDecoder.isExpired(token) == false) {
    return true;
  }

  return false;
}

class Tiffinwala extends StatefulWidget {
  final String? token;
  const Tiffinwala({super.key, required this.token});

  @override
  State<Tiffinwala> createState() => _TiffinwalaState();
}

late bool token;

class _TiffinwalaState extends State<Tiffinwala> {
  @override
  void initState() {
    token = isTokenValid(widget.token);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Tiffinwala',
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      theme: ThemeData(colorScheme: ColorSchemes.darkNeutral(), radius: 0.5),
      // home: token ? const Menu() : const Auth(),
      home: Profile(),
    );
  }
}

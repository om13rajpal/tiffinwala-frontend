import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/screens/auth.dart';
import 'package:tiffinwala/screens/menu.dart';

void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

  WidgetsFlutterBinding.ensureInitialized();
  runApp(Tiffinwala(token: token));
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
      theme: ThemeData(colorScheme: ColorSchemes.darkGreen(), radius: 0.5),
      home: token ? const Menu() : const Auth(),
    );
  }
}

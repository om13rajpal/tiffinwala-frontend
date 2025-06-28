import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/screens/auth.dart';
import 'package:tiffinwala/screens/menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('token');

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
  @override
  void initState() {
    super.initState();
    bool valid = isTokenValid(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).state = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(authProvider);

    return ShadcnApp(
      title: 'Tiffinwala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorSchemes.darkNeutral(), radius: 0.5),
      home: isAuth ? const Menu() : const Auth(),
    );
  }
}

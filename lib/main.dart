import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/screens/auth.dart';

void main() {
  runApp(const Tiffinwala());
}

class Tiffinwala extends StatelessWidget {
  const Tiffinwala({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Tiffinwala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorSchemes.darkGreen(), radius: 0.5),
      home: Auth(),
    );
  }
}

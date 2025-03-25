import 'package:shadcn_flutter/shadcn_flutter.dart';

class Otp extends StatelessWidget {
  const Otp({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 25,
      child: InputOTP(
        children: [
          InputOTPChild.character(allowDigit: true),
          InputOTPChild.character(allowDigit: true),
          InputOTPChild.character(allowDigit: true),
          InputOTPChild.separator,
          InputOTPChild.character(allowDigit: true),
          InputOTPChild.character(allowDigit: true),
          InputOTPChild.character(allowDigit: true),
        ],
      ),
    );
  }
}

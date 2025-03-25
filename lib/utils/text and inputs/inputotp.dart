import 'package:shadcn_flutter/shadcn_flutter.dart';

class Otp extends StatelessWidget {
  final Function(String) otpHandler;
  const Otp({super.key, required this.otpHandler});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 25,
      child: InputOTP(
        onSubmitted: (value) => otpHandler(value.otpToString()),
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

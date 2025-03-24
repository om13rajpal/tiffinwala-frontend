import 'package:flutter/material.dart';
import 'package:tiffinwala/utils/modal%20pages/otp.dart';
import 'package:tiffinwala/utils/modal%20pages/phone.dart';
import 'package:tiffinwala/utils/modal%20pages/userDetails.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                WoltModalSheet.show(
                  context: context,
                  pageListBuilder: (context) {
                    final textTheme = Theme.of(context).textTheme;
                    return [
                      phone(context, textTheme),
                      otp(context, textTheme),
                      userDetails(context, textTheme),
                    ];
                  },
                );
              },
              child: Text('show'),
            ),
          ),
        ),
      ),
    );
  }
}

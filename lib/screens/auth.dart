import 'package:flutter/material.dart';
import 'package:tiffinwala/utils/modal%20pages/phone.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
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

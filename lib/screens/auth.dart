import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/providers/loading.dart';
import 'package:tiffinwala/utils/modal%20pages/phone.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Auth extends ConsumerStatefulWidget {
  const Auth({super.key});

  @override
  ConsumerState<Auth> createState() => _AuthState();
}

class _AuthState extends ConsumerState<Auth> {
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
                ref.read(isLoadingProvider.notifier).setLoading(false);
                WoltModalSheet.show(
                  context: context,
                  pageListBuilder: (context) {
                    final textTheme = Theme.of(context).textTheme;
                    return [phone(context, textTheme, ref)];
                  },
                );
              },
              child: Text('Get In'),
            ),
          ),
        ),
      ),
    );
  }
}

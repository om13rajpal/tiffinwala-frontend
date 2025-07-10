import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          color: const Color.fromARGB(255, 21, 21, 21),
          child: Stack(
            children: [
              Image.asset(
                'assets/background/main.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        'Tiffin Wala',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 41,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Positioned(
                        top: -18,
                        left: -3.5,
                        child: LucideIconWidget(
                          icon: LucideIcons.chefHat,
                          size: 30,
                          strokeWidth: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 140,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      '~ Home like food at your doorstep',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 126, 126, 126),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 89, 89, 89),
                      ),
                    ),
                    onPressed: () {
                      ref.read(isLoadingProvider.notifier).setLoading(false);
                      WoltModalSheet.show(
                        barrierDismissible: false,
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
            ],
          ),
        ),
      ),
    );
  }
}

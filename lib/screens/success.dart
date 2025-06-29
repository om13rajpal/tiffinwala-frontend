import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class Success extends StatefulWidget {
  final String id;
  const Success({super.key, required this.id});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      redirect();
    });
    super.initState();
  }

  void redirect() async {
    await Future.delayed(7000.ms);
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/lottie/order.json',
              renderCache: RenderCache.raster,
              backgroundLoading: true,
              repeat: false,
            ),
            Text(
              'Your order has been received',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 227, 227, 227),
              ),
            ),
            Text(
              '~ Order ID: ${widget.id}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 193, 193, 193),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

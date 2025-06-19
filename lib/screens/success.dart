import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class Success extends StatefulWidget {
  const Success({super.key});

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
    await Future.delayed(4000.ms);
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: LottieBuilder.asset(
          'assets/lottie/order.json',
          renderCache: RenderCache.raster,
        ),
      ),
    );
  }
}

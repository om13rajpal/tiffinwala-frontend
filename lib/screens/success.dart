import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class Success extends StatefulWidget {
  final String title;
  final String message;
  final Map<String, String>? details;
  final String? lottieAsset;

  const Success({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.lottieAsset,
  });

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
    await Future.delayed(6000.ms);
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  widget.lottieAsset ?? 'assets/lottie/order.json',
                  renderCache: RenderCache.raster,
                  backgroundLoading: true,
                  repeat: false,
                ),
                SizedBox(height: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.details != null && widget.details!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  ...widget.details!.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${e.key}: ${e.value}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
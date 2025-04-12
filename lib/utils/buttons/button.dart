import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/providers/loading.dart';

class TiffinButton extends ConsumerWidget {
  final String label;
  final double width;
  final double height;
  final VoidCallback onPressed;
  const TiffinButton({
    super.key,
    required this.label,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = ref.watch(isLoadingProvider);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: (isLoading) ? WidgetStatePropertyAll(Color(0xFF303030)) : WidgetStatePropertyAll(Color(0xFF3E3E3E)),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: (isLoading) ? null : onPressed,
        child:
            (isLoading)
                ? LottieBuilder.network('https://lottie.host/f1e43fa6-225b-4970-9551-b8f957320885/TGqIHoNNlE.json', width: 20, frameRate: FrameRate.max,)
                : Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
      ),
    );
  }
}

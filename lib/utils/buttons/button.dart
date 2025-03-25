import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors/colors.dart';

class TiffinButton extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final VoidCallback onPressed;
  const TiffinButton({
    super.key,
    required this.label,
    required this.width,
    required this.height, required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xFF3E3E3E)),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: onPressed,
        child: Text(
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

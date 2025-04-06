import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  const GradientText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [Color(0xFFFF40C9), Color(0xFFFF0099), Color(0xFFF7BB97)],
            stops: [0.0, 0.3, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

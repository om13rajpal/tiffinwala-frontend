import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText({super.key});

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
        "Get In",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

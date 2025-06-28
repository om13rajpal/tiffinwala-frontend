import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 177, 177, 177),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
      child: Text('Verified User', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black),),
    );
  }
}
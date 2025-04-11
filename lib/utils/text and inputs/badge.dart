import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Text('Verified', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.black),),
    );
  }
}
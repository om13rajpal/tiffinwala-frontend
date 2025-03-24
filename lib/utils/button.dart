import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class TiffinButton extends StatelessWidget {
  const TiffinButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 28,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xFF3E3E3E)),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: () {
          WoltModalSheet.of(context).showNext();
        },
        child: Text(
          'GET IN',
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

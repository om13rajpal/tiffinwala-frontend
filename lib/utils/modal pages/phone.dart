import 'package:flutter/material.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/input.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage phone(BuildContext context, TextTheme textTheme) {
  return WoltModalSheetPage(
    child: SizedBox(),
    heroImageHeight: 220,
    heroImage: Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          const Row(
            children: [
              Text(
                'Hola amigo!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5),
              GradientText(),
            ],
          ),
          const Input(prefix: true, label: 'Phone Number', hint: 'Phone Number'),
          TiffinButton(
            label: 'GET IN',
            width: 65,
            height: 28,
            onPressed: () {
              WoltModalSheet.of(context).showNext();
            },
          ),
        ],
      ),
    ),
  );
}

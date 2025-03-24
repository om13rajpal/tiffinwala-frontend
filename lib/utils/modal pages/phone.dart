import 'package:flutter/material.dart';
import 'package:tiffinwala/utils/button.dart';
import 'package:tiffinwala/utils/gradientext.dart';
import 'package:tiffinwala/utils/input.dart';
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
          Row(
            children: [
              Text(
                'Hola amigo!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5),
              GradientText(),
            ],
          ),
          Input(),
          TiffinButton(),
        ],
      ),
    ),
  );
}

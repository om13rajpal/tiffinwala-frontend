import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/screens/menu.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/input.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage userDetails(
  BuildContext context,
  TextTheme textTheme,
) {
  return WoltModalSheetPage(
    child: SizedBox(),
    topBar: Center(
      child: Text(
        'Enter your details',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    isTopBarLayerAlwaysVisible: true,
    useSafeArea: true,
    leadingNavBarWidget: Padding(
      padding: const EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: () {
          WoltModalSheet.of(context).showPrevious();
        },
        child: LucideIconWidget(
          icon: LucideIcons.arrowUpLeft,
          size: 18,
          strokeWidth: 2,
        ),
      ),
    ),
    heroImageHeight: 310,
    heroImage: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Input(prefix: false, label: 'First Name', hint: 'John'),
          const Input(prefix: false, label: 'Last Name', hint: 'Doe'),
          const Input(prefix: false, label: 'Address', hint: 'Street xyz, Patiala'),
          TiffinButton(
            label: 'SAVE',
            width: 65,
            height: 28,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
          ),
        ],
      ),
    ),
  );
}

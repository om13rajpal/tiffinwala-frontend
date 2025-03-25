import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/inputotp.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage otp(BuildContext context, TextTheme textTheme) {
  return WoltModalSheetPage(
    topBar: const Center(
      child: Text(
        'Enter the OTP',
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
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        spacing: 10,
        children: [
          const Otp(),
          TiffinButton(
            label: 'VERIFY',
            width: 70,
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

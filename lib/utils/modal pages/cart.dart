import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/utils/cartitems.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/bill.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/paynow.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage cart(
  BuildContext context,
  final void Function(String method)? openCheckout,
  VoidCallback cod,
  int loyaltyPoints,
  WidgetRef ref,
) {

  return WoltModalSheetPage(
    pageTitle: Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'View your',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 5),
          Transform.translate(
            offset: Offset(0, 1),
            child: GradientText(text: 'Cart'),
          ),
        ],
      ),
    ),
    stickyActionBar: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Paynow((method) => openCheckout?.call(method), loyaltyPoints, cod),
    ),
    forceMaxHeight: false,
    child: Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            CartItem(),
            Container(
              height: 0.8,
              width: double.infinity,
              decoration: BoxDecoration(
                border: DashedBorder.fromBorderSide(
                  side: const BorderSide(
                    color: Color.fromARGB(255, 179, 179, 179),
                    width: 0.2,
                  ),
                  dashLength: 2.5,
                  spaceLength: 3,
                ),
              ),
            ),
            Bill(),
            SizedBox(height: 100),
          ],
        ),
      ),
    ),
  );
}

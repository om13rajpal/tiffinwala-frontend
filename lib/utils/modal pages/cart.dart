import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/utils/cartitems.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/paynow.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage cart(
  BuildContext context,
  VoidCallback openCheckout,
  VoidCallback cod,
  int loyaltyPoints,
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
      child: Paynow(openCheckout, loyaltyPoints, cod),
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
            Column(
              spacing: 2,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 212, 212, 212),
                      ),
                    ),
                    Text(
                      totalPrice.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color.fromARGB(255, 184, 184, 184),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'CGST (2.5%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 212, 212, 212),
                      ),
                    ),
                    Text(
                      (totalPrice * 0.025).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color.fromARGB(255, 184, 184, 184),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'SGST (2.5%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 212, 212, 212),
                      ),
                    ),
                    Text(
                      (totalPrice * 0.025).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color.fromARGB(255, 184, 184, 184),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Delivery Charges',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 212, 212, 212),
                      ),
                    ),
                    Text(
                      '20',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color.fromARGB(255, 184, 184, 184),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: const Color.fromARGB(255, 49, 49, 49),
                  thickness: 0.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Amount Payable',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: const Color.fromARGB(255, 212, 212, 212),
                      ),
                    ),
                    Text(
                      (totalPrice + (totalPrice * 0.05) + 20).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                        color: const Color.fromARGB(255, 184, 184, 184),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            SizedBox(height: 100),
          ],
        ),
      ),
    ),
  );
}

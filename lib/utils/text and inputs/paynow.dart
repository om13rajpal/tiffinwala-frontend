import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/coupon.dart';
import 'package:tiffinwala/providers/loyalty.dart';
import 'package:tiffinwala/providers/points.dart';
import 'package:tiffinwala/screens/menu.dart';
import 'package:tiffinwala/screens/payment.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';
import 'package:http/http.dart' as http;

class Paynow extends ConsumerStatefulWidget {
  final void Function(String method)? openCheckout;
  final VoidCallback cod;
  final int loyaltyPoints;
  const Paynow(this.openCheckout, this.loyaltyPoints, this.cod, {super.key});

  @override
  ConsumerState<Paynow> createState() => _PaynowState();
}

double totalPrice = 0.0;
double loyaltyPrice = 0.0;
bool usingLoyaltyPoints = false;
late String usingCoupon;
int discount = 0;

TextEditingController coupon = TextEditingController();

class _PaynowState extends ConsumerState<Paynow> {
  void handleCheckbox(bool isChecked) {
    ref.read(isUsingLoyaltyProvider.notifier).setLoading(isChecked);
    setState(() {
      usingLoyaltyPoints = isChecked;
    });
  }

  void verifyCoupon() async {
    final body = {"code": coupon.text.trim().toLowerCase()};

    final response = await http.post(
      Uri.parse("${BaseUrl.url}/coupon/verify"),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    final jsonRes = await jsonDecode(response.body);
    if (response.statusCode == 200) {
      usingCoupon = coupon.text.trim();
      ref.read(couponProvider.notifier).setCoupon(discount);
      setState(() {
        final dis = jsonRes["data"]["discount"];
        discount = dis;
      });
    }
  }

  void removeCoupon() async {
    ref.read(couponProvider.notifier).reset();
    discount = 0;
    coupon.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    loyaltyPoints = ref.watch(setPointsProvider);
    List<CartItems> cartItems = ref.watch(cartProvider);
    final couponUsed = ref.watch(couponProvider).verified;

    totalPrice = ref.watch(
      cartProvider.notifier.select((cart) => cart.getTotalPrice(discount)),
    );

    loyaltyPrice =
        ref.watch(
          cartProvider.notifier.select((cart) => cart.getTotalPrice(discount)),
        ) -
        widget.loyaltyPoints;

    if (loyaltyPrice < 0) {
      loyaltyPrice = 0;
    }

    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: SizedBox(
                height: 35,
                child: TextField(
                  controller:
                      (couponUsed)
                          ? TextEditingController(text: usingCoupon)
                          : coupon,
                  readOnly: couponUsed,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                  onChanged: (value) {},
                  cursorOpacityAnimates: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 9),
                    hintText: 'Coupon',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondary.withAlpha(100),
                    ),
                    filled: true,
                    fillColor: AppColors.accent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(LucideIcons.badgePercent, size: 16),
                    suffixIcon:
                        (couponUsed)
                            ? InkWell(
                              onTap: () => removeCoupon(),
                              child: Icon(LucideIcons.x, size: 16),
                            )
                            : InkWell(
                              onTap: () {
                                verifyCoupon();
                              },
                              child: Icon(LucideIcons.chevronRight, size: 16),
                            ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text('Use loyalty points', style: TextStyle(fontSize: 10)),
                Transform.translate(
                  offset: Offset(-7, 0),
                  child: Row(
                    children: [
                      TiffinCheckbox(
                        preChecked: false,
                        onChanged: (isChecked) {
                          handleCheckbox(isChecked);
                        },
                      ),
                      Text(
                        '₹${widget.loyaltyPoints} off',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cartItems.length} items in cart',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  (usingLoyaltyPoints)
                      ? '₹ ${loyaltyPrice.toStringAsFixed(2)}'
                      : '₹ ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            TiffinButton(
              label: 'PAYMENT',
              width: 75,
              height: 27,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentPage(
                          openCheckout: widget.openCheckout,
                          cod: widget.cod,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

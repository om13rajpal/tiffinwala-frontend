import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/coupon.dart';
import 'package:tiffinwala/providers/discount.dart';
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

TextEditingController coupon = TextEditingController();

class _PaynowState extends ConsumerState<Paynow> {
  void handleCheckbox(bool isChecked) {
    if (isChecked) {
      ref
          .read(discountProvider.notifier)
          .setLoyaltyDiscount(widget.loyaltyPoints.toDouble());
    } else {
      ref.read(discountProvider.notifier).setLoyaltyDiscount(0.0);
    }
  }

  void verifyCoupon() async {
    final body = {"code": coupon.text.trim().toLowerCase()};

    final response = await http.post(
      Uri.parse("${BaseUrl.url}/coupon/verify"),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );

    final jsonRes = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final dis = jsonRes["data"]["discount"].toDouble();

      ref.read(discountProvider.notifier).setCouponDiscount(dis);
      ref.read(couponProvider.notifier).setCoupon(dis.toInt());
      setState(() {});
    }
  }

  void removeCoupon() {
    ref.read(discountProvider.notifier).setCouponDiscount(0.0);
    ref.read(couponProvider.notifier).reset();
    coupon.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final discountState = ref.watch(discountProvider);
    final couponUsed = ref.watch(couponProvider).verified;

    List<CartItems> cartItems = ref.watch(cartProvider);

    final totalPayable = ref.watch(
      cartProvider.notifier.select(
        (cart) => cart.getPayableAmount(
          discountState.couponDiscount,
          discountState.loyaltyDiscount,
        ),
      ),
    );

    final loyaltyApplied = discountState.loyaltyDiscount > 0;


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
                      couponUsed
                          ? TextEditingController(text: coupon.text)
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
                        couponUsed
                            ? InkWell(
                              onTap: removeCoupon,
                              child: Icon(LucideIcons.x, size: 16),
                            )
                            : InkWell(
                              onTap: verifyCoupon,
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
                        preChecked: loyaltyApplied,
                        onChanged: handleCheckbox,
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
                  '₹ ${totalPayable.toStringAsFixed(2)}',
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

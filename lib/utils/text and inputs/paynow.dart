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

final coldDrinkProvider = StateProvider<bool>((ref) => false);
final chocolateMousseProvider = StateProvider<bool>((ref) => false);

class Paynow extends ConsumerStatefulWidget {
  final void Function(String method)? openCheckout;
  final VoidCallback cod;
  final int loyaltyPoints;
  final double totalPrice;

  const Paynow(this.openCheckout, this.loyaltyPoints, this.cod, this.totalPrice, {super.key});

  @override
  ConsumerState<Paynow> createState() => _PaynowState();
}

TextEditingController coupon = TextEditingController();

class _PaynowState extends ConsumerState<Paynow> {
  bool verifying = false;

  void handleCheckbox(bool isChecked) {
    if (isChecked) {
      ref.read(discountProvider.notifier).setLoyaltyDiscount(widget.loyaltyPoints.toDouble());
    } else {
      ref.read(discountProvider.notifier).setLoyaltyDiscount(0.0);
    }
  }

  void verifyCoupon() async {
    if (coupon.text.trim().isEmpty) return;

    setState(() {
      verifying = true;
    });

    final body = {"code": coupon.text.trim(), "price": widget.totalPrice};

    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/coupon/verifyCoupon"),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );

      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        double discount = 0;
        final discountValue = jsonRes["data"]["discount"];
        if (discountValue is int) {
          discount = discountValue.toDouble();
        } else if (discountValue is double) {
          discount = discountValue;
        }

        final cartItems = ref.read(cartProvider);
        final cartNotifier = ref.read(cartProvider.notifier);
        final code = coupon.text.trim().toUpperCase();

        if (code == "BOGO" || code == "B2G1" || code == "B3G1") {
          int requiredQty = 1;
          if (code == "B2G1") requiredQty = 2;
          if (code == "B3G1") requiredQty = 3;

          int totalQty = cartItems.fold(0, (sum, item) => sum + item.quantity);
          if (totalQty >= requiredQty + 1) {
            CartItems? lowest;
            for (final item in cartItems) {
              if (lowest == null || item.totalPrice < lowest.totalPrice) {
                lowest = item;
              }
            }
            if (lowest != null) {
              final updatedCart = cartItems.map((item) {
                if (item == lowest) {
                  return CartItems(
                    item.item,
                    0.0,
                    item.options,
                    item.quantity,
                    item.optionSet,
                    originalPrice: item.totalPrice,
                  );
                }
                return item;
              }).toList();
              cartNotifier.state = updatedCart;
            }
          } else {
            removeCoupon();
            return;
          }
        }

        if (code == "COLDDRINK" && widget.totalPrice >= 179) {
          ref.read(coldDrinkProvider.notifier).state = true;
        }

        if (code == "SWEET" && widget.totalPrice >= 249) {
          ref.read(chocolateMousseProvider.notifier).state = true;
        }

        ref.read(discountProvider.notifier).setCouponDiscount(discount);
        ref.read(couponProvider.notifier).setCoupon(discount.toInt(), coupon.text.trim());

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Coupon applied successfully!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
          ),
        );
        setState(() {});
      } else {
        removeCoupon();
        final errorMsg = jsonRes["message"] ?? "Failed to apply coupon.";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error verifying coupon. Please try again.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        verifying = false;
      });
    }
  }

  void removeCoupon() {
    ref.read(discountProvider.notifier).setCouponDiscount(0.0);
    ref.read(couponProvider.notifier).reset();
    ref.read(coldDrinkProvider.notifier).state = false;
    ref.read(chocolateMousseProvider.notifier).state = false;

    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = ref.read(cartProvider);

    final restoredCart = cartItems.map((item) {
      return CartItems(
        item.item,
        item.originalPrice,
        item.options,
        item.quantity,
        item.optionSet,
        originalPrice: item.originalPrice,
      );
    }).toList();

    cartNotifier.state = restoredCart;
    coupon.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final discountState = ref.watch(discountProvider);
    final couponUsed = ref.watch(couponProvider).verified;
    List<CartItems> cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalPayable = cartNotifier.getPayableAmount(
      ref,
      couponPercent: discountState.couponDiscount,
      loyaltyPoints: discountState.loyaltyDiscount,
    );

    final loyaltyApplied = discountState.loyaltyDiscount > 0;
    final couponCode = ref.read(couponProvider).code;

    if ((couponCode == "BOGO" || couponCode == "B2G1" || couponCode == "B3G1")) {
      int requiredQty = 1;
      if (couponCode == "B2G1") requiredQty = 2;
      if (couponCode == "B3G1") requiredQty = 3;

      int totalQty = cartItems.fold(0, (sum, item) => sum + item.quantity);

      if (totalQty < requiredQty + 1) {
        Future.microtask(() => removeCoupon());
      }
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
                  controller: couponUsed ? TextEditingController(text: coupon.text) : coupon,
                  readOnly: couponUsed,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 9),
                    hintText: 'Coupon',
                    hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.secondary.withAlpha(100)),
                    filled: true,
                    fillColor: AppColors.accent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(LucideIcons.badgePercent, size: 16),
                    suffixIcon: verifying
                        ? SizedBox(
                            height: 14,
                            width: 14,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                            ),
                          )
                        : couponUsed
                            ? InkWell(onTap: removeCoupon, child: Icon(LucideIcons.x, size: 16))
                            : InkWell(onTap: verifyCoupon, child: Icon(LucideIcons.chevronRight, size: 16)),
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
                      TiffinCheckbox(preChecked: loyaltyApplied, onChanged: handleCheckbox),
                      Text('₹${widget.loyaltyPoints} off', style: TextStyle(fontSize: 12)),
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
                Text('${cartItems.length} items in cart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.secondary)),
                Text('₹ ${totalPayable.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.secondary)),
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
                    builder: (context) => PaymentPage(openCheckout: widget.openCheckout, cod: widget.cod),
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
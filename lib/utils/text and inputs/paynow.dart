import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';

class Paynow extends ConsumerStatefulWidget {
  final VoidCallback openCheckout;
  final VoidCallback cod;
  final int loyaltyPoints;
  const Paynow(this.openCheckout, this.loyaltyPoints, this.cod, {super.key});

  @override
  ConsumerState<Paynow> createState() => _PaynowState();
}

double totalPrice = 0.0;
double loyaltyPrice = 0.0;
bool usingLoyaltyPoints = false;

class _PaynowState extends ConsumerState<Paynow> {
  void handleCheckbox(bool isChecked) {
    setState(() {
      usingLoyaltyPoints = isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CartItems> cartItems = ref.watch(cartProvider);
    totalPrice = ref.watch(
      cartProvider.notifier.select((cart) => cart.getTotalPrice()),
    );

    loyaltyPrice =
        ref.watch(
          cartProvider.notifier.select((cart) => cart.getTotalPrice()),
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
                    suffixIcon: Icon(LucideIcons.chevronRight, size: 16),
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
                  (usingLoyaltyPoints) ? '₹ $loyaltyPrice' : '₹ $totalPrice',
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppColors.accent,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.cod();
                            },
                            child: Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.openCheckout,
                            child: Text(
                              'Pay Online',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

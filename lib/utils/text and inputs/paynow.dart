import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/loyalty.dart';
import 'package:tiffinwala/providers/points.dart';
import 'package:tiffinwala/screens/menu.dart';
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
    ref.read(isUsingLoyaltyProvider.notifier).setLoading(isChecked);
    setState(() {
      usingLoyaltyPoints = isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    loyaltyPoints = ref.watch(setPointsProvider);
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
                    suffixIcon: InkWell(
                      onTap: () => print('Apply coupon'),
                      child: Icon(LucideIcons.chevronRight, size: 16)),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.accent,
                      content: SizedBox(
                        height: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            const SizedBox(height: 5),
                            Divider(
                              color: const Color.fromARGB(255, 77, 77, 77),
                              thickness: 1,
                            ),
                            GestureDetector(
                              onTap: () => widget.openCheckout(),
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

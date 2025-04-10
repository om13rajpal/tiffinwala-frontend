import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/buttons/button.dart';

class Paynow extends ConsumerStatefulWidget {
  final VoidCallback openCheckout;
  const Paynow(this.openCheckout, {super.key});

  @override
  ConsumerState<Paynow> createState() => _PaynowState();
}

class _PaynowState extends ConsumerState<Paynow> {
  @override
  Widget build(BuildContext context) {
    List<CartItems> cartItems = ref.watch(cartProvider);
    double totalPrice = ref.watch(
      cartProvider.notifier.select((cart) => cart.getTotalPrice()),
    );

    return Row(
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
              '₹ $totalPrice',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        TiffinButton(
          label: 'PAY NOW',
          width: 70,
          height: 27,
          onPressed: widget.openCheckout,
        ),
      ],
    );
  }
}

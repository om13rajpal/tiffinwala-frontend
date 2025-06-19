import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/coupon.dart';

class Bill extends ConsumerStatefulWidget {
  const Bill({super.key});

  @override
  ConsumerState<Bill> createState() => _BillState();
}

double total = 0.0;

class _BillState extends ConsumerState<Bill> {
  @override
  Widget build(BuildContext context) {
    ref.watch(couponProvider);
    ref.watch(cartProvider);

    final discount = ref.watch(couponProvider.select((c) => c.discount));
    total = ref.watch(
      cartProvider.notifier.select((cart) => cart.getTotalPrice(discount)),
    );

    return Column(
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
              total.toString(),
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
              (total * 0.025).toStringAsFixed(2),
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
              (total * 0.025).toStringAsFixed(2),
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
        Divider(color: const Color.fromARGB(255, 49, 49, 49), thickness: 0.5),
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
              total.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                color: const Color.fromARGB(255, 184, 184, 184),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

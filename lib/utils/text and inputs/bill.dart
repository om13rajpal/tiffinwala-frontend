import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/coupon.dart';
import 'package:tiffinwala/providers/discount.dart';
import 'package:tiffinwala/providers/charge.dart';

class Bill extends ConsumerStatefulWidget {
  const Bill({super.key});

  @override
  ConsumerState<Bill> createState() => _BillState();
}

class _BillState extends ConsumerState<Bill> {
  @override
  Widget build(BuildContext context) {
    // Listen to relevant providers
    ref.watch(couponProvider);
    ref.watch(cartProvider);

    final discountState = ref.watch(discountProvider);
    final couponDiscount = discountState.couponDiscount;

    final subtotal = ref.watch(
      cartProvider.notifier.select((cart) => cart.getNormalTotalPrice()),
    );

    // cap loyalty discount so it does not exceed subtotal
    final loyaltyDiscount =
        discountState.loyaltyDiscount > subtotal
            ? subtotal
            : discountState.loyaltyDiscount;

    double discountedSubtotal = subtotal - loyaltyDiscount - couponDiscount;
    if (discountedSubtotal < 0) discountedSubtotal = 0;
    // Read charges from provider
    final charges = ref.watch(chargesProvider);
    final packagingChargePerItem = charges['packagingCharge'] ?? 0.0;
    final deliveryCharge = charges['deliveryCharge'] ?? 0.0;

    // Calculate total quantity in cart
    final totalQuantity = ref.read(cartProvider.notifier).getTotalQuantity();

    final packagingCharge = packagingChargePerItem * totalQuantity;

    final amountPayable = discountedSubtotal + packagingCharge + deliveryCharge;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 33, 33, 33),
      ),
      child: shadcn.Accordion(
        items: [
          shadcn.AccordionItem(
            trigger: shadcn.AccordionTrigger(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Total bill amount',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '₹ ${amountPayable.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Total Price', subtotal.toStringAsFixed(2)),
                if (loyaltyDiscount > 0)
                  _buildRow(
                    'Loyalty Discount',
                    '- ${loyaltyDiscount.toStringAsFixed(2)}',
                  ),
                if (couponDiscount > 0)
                  _buildRow(
                    'Promotional Discount',
                    '- ${couponDiscount.toStringAsFixed(2)}',
                  ),
                if (packagingCharge > 0)
                  _buildRow(
                    'Packaging Charges',
                    packagingCharge.toStringAsFixed(2),
                  ),
                if (deliveryCharge > 0)
                  _buildRow(
                    'Delivery Charges',
                    deliveryCharge.toStringAsFixed(2),
                  ),
                const Divider(
                  color: Color.fromARGB(255, 89, 89, 89),
                  thickness: 0.5,
                ),
                _buildRow(
                  'Amount Payable',
                  amountPayable.toStringAsFixed(2),
                  isHighlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              fontSize: isHighlight ? 14 : 12.5,
              color: const Color.fromARGB(255, 212, 212, 212),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              fontSize: isHighlight ? 13 : 12,
              color: const Color.fromARGB(255, 184, 184, 184),
            ),
          ),
        ],
      ),
    );
  }
}

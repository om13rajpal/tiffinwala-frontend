import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/coupon.dart';
import 'package:tiffinwala/providers/discount.dart';

class Bill extends ConsumerStatefulWidget {
  const Bill({super.key});

  @override
  ConsumerState<Bill> createState() => _BillState();
}

class _BillState extends ConsumerState<Bill> {
  @override
  Widget build(BuildContext context) {
    ref.watch(couponProvider);
    ref.watch(cartProvider);

    final discountState = ref.watch(discountProvider);
    final loyaltyDiscount = discountState.loyaltyDiscount;
    final couponDiscount = discountState.couponDiscount;

    final subtotal = ref.watch(
      cartProvider.notifier.select((cart) => cart.getNormalTotalPrice()),
    );

    double discountedSubtotal = subtotal - loyaltyDiscount - couponDiscount;
    if (discountedSubtotal < 0) discountedSubtotal = 0;

    final cgst = discountedSubtotal * 0.025;
    final sgst = discountedSubtotal * 0.025;
    const deliveryCharges = 20.0;

    final amountPayable = discountedSubtotal + cgst + sgst + deliveryCharges;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
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
                  Text('Total bill amount', style: TextStyle(fontSize: 14)),
                  Text(
                    '₹ ${amountPayable.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14),
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
                _buildRow('CGST (2.5%)', cgst.toStringAsFixed(2)),
                _buildRow('SGST (2.5%)', sgst.toStringAsFixed(2)),
                _buildRow(
                  'Delivery Charges',
                  deliveryCharges.toStringAsFixed(2),
                ),
                Divider(
                  color: const Color.fromARGB(255, 89, 89, 89),
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

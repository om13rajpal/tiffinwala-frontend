import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/paymenttile.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/bill.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final void Function(String method)? openCheckout;
  final VoidCallback? cod;

  const PaymentPage({this.openCheckout, this.cod, super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

final selectedPaymentProvider = StateProvider<String?>((ref) => null);

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final List<String> paymentMethods = [
    'UPI',
    'Credit Card',
    'Debit Card',
    'Net Banking',
    'Wallet',
    'Cash on Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPayment = ref.watch(selectedPaymentProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  TiffinAppBar(centerTitle: true, title: 'Payment'),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Payment Methods',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA0A3B0),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: List.generate(paymentMethods.length, (index) {
                          final method = paymentMethods[index];
                          return GestureDetector(
                            onTap: () async {
                              ref.read(selectedPaymentProvider.notifier).state =
                                  method;
                            },
                            child: PaymentDetailsTile(
                              title: method,
                              badge:
                                  selectedPayment == method ? 'Selected' : '',
                              icon: _getPaymentIcon(method),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 25)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA0A3B0),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212121),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(100),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Bill(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFF000000),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.2],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: ElevatedButton(
                          onPressed: selectedPayment != null
                              ? () {
                                  if (selectedPayment == 'Cash on Delivery') {
                                    widget.cod?.call();
                                  } else {
                                    widget.openCheckout?.call(selectedPayment);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF285531),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            selectedPayment != null
                                ? 'Pay with $selectedPayment'
                                : 'Select a Payment Method',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'UPI':
        return LucideIcons.indianRupee;
      case 'Credit Card':
        return LucideIcons.creditCard;
      case 'Debit Card':
        return LucideIcons.creditCard;
      case 'Net Banking':
        return LucideIcons.banknote;
      case 'Wallet':
        return LucideIcons.wallet;
      case 'Cash on Delivery':
        return LucideIcons.package;
      default:
        return Icons.payment;
    }
  }
}
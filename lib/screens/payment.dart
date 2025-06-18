import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/paymenttile.dart';

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
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: List.generate(paymentMethods.length, (index) {
                      final method = paymentMethods[index];
                      return GestureDetector(
                        onTap: () async {
                          ref.read(selectedPaymentProvider.notifier).state =
                              method;

                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );

                          if (method == 'Cash on Delivery') {
                            widget.cod?.call();
                          } else {
                            widget.openCheckout?.call(
                              method,
                            );
                          }
                        },
                        child: PaymentDetailsTile(
                          title: method,
                          badge: selectedPayment == method ? 'Selected' : '',
                          icon: _getPaymentIcon(method),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
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

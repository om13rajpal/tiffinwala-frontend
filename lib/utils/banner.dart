import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/paynow.dart';

class FreeItemBanner extends ConsumerWidget {
  const FreeItemBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasColdDrink = ref.watch(coldDrinkProvider);
    final hasChocolateMousse = ref.watch(chocolateMousseProvider);

    if (!hasColdDrink && !hasChocolateMousse) return SizedBox.shrink();

    String freeItemText = '';
    if (hasColdDrink) {
      freeItemText = '🎉 Free Cold Drink added to your cart!';
    } else if (hasChocolateMousse) {
      freeItemText = '🎉 Free Chocolate Mousse added to your cart!';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: Text(
        freeItemText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.green[700],
        ),
      ),
    );
  }
}

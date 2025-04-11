import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';

class CartItem extends ConsumerWidget {
  const CartItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<CartItems> cartItems = ref.watch(cartProvider);
    return Column(
      children: List.generate(cartItems.length, (index) {
        return ItemDetails(
          isCartItem: true,
          price: cartItems[index].totalPrice.toInt(),
          title: cartItems[index].item['itemName'],
          optionSet: cartItems[index].options,
          item: cartItems[index].item,
          index: index,
        );
      }),
    );
  }
}

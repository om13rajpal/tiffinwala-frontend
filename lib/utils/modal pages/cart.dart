import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage cart(
  BuildContext context,
  VoidCallback openCheckout,
  WidgetRef ref,
) {
  List<CartItems> cartItems = ref.watch(cartProvider);
  double price = ref.watch(
    cartProvider.notifier.select((cart) => cart.getTotalPrice()),
  );
  return WoltModalSheetPage(
    pageTitle: Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Row(
        children: [
          Text(
            'View your',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 5),
          GradientText(text: 'Cart'),
        ],
      ),
    ),
    stickyActionBar: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Row(
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
                '₹ $price',
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
            onPressed: openCheckout,
          ),
        ],
      ),
    ),
    forceMaxHeight: false,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          Column(
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
          ),
          SizedBox(height: 50),
        ],
      ),
    ),
  );
}

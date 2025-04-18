import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/providers/veg.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';

class Category extends ConsumerWidget {
  final String title;
  final List<dynamic> items;
  const Category({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVeg = ref.watch(isVegProvider);
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(46),
            topRight: Radius.circular(46),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: SizedBox(
            height: 100,
            width: double.infinity,
            child: Stack(
              children: [
                Image.asset(
                  'assets/background/back_gif.gif',
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  isAntiAlias: true,
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(items.length, (index) {
            if (items[index]['item']['price'] == null ||
                items[index]['item']['itemName'] == null) {
              return Container();
            }

            if (isVeg) {
              if (items[index]['item']['itemTagIds'][0] == Classification.veg) {
                if (index == 0) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: DashedBorder.fromBorderSide(
                        side: const BorderSide(color: Colors.black, width: 0.2),
                        dashLength: 2.5,
                        spaceLength: 2.5,
                      ),
                    ),
                    child: ItemDetails(
                      isCartItem: false,
                      price: items[index]['item']['price'],
                      title: items[index]['item']['itemName'],
                      optionSet: items[index]['optionSet'],
                      item: items[index]['item'],
                      index: index,
                    ),
                  );
                }
                return ItemDetails(
                  isCartItem: false,
                  price: items[index]['item']['price'],
                  title: items[index]['item']['itemName'],
                  optionSet: items[index]['optionSet'],
                  item: items[index]['item'],
                  index: index,
                );
              } else {
                return Container();
              }
            } else {
              if (index == 0) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: DashedBorder.fromBorderSide(
                      side: const BorderSide(color: Colors.black, width: 0.2),
                      dashLength: 2.5,
                      spaceLength: 2.5,
                    ),
                  ),
                  child: ItemDetails(
                    isCartItem: false,
                    price: items[index]['item']['price'],
                    title: items[index]['item']['itemName'],
                    optionSet: items[index]['optionSet'],
                    item: items[index]['item'],
                    index: index,
                  ),
                );
              }
              return ItemDetails(
                isCartItem: false,
                price: items[index]['item']['price'],
                title: items[index]['item']['itemName'],
                optionSet: items[index]['optionSet'],
                item: items[index]['item'],
                index: index,
              );
            }
          }),
        ),
      ],
    );
  }
}
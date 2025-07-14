import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/providers/veg.dart';
import 'package:tiffinwala/utils/text and inputs/itemdetails.dart';

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
        /// Category header
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

        /// Items in this category
        Column(
          children: _buildItemsList(isVeg),
        ),
      ],
    );
  }

  List<Widget> _buildItemsList(bool isVeg) {
    List<Widget> widgets = [];

    for (int index = 0; index < items.length; index++) {
      final itemData = items[index]['item'];
      final optionSet = items[index]['optionSet'];
      final price = itemData['price'];
      final name = itemData['itemName'];
      final description = itemData['description'] ?? "";

      if (price == null || name == null) {
        continue;
      }

      /// veg filtering logic
      if (isVeg) {
        final tagIds = itemData['itemTagIds'] as List?;
        if (tagIds == null || tagIds.isEmpty) {
          continue;
        }
        if (tagIds[0] != Classification.veg) {
          continue;
        }
      }

      /// Build item widget
      Widget itemWidget = ItemDetails(
        isCartItem: false,
        description: description,
        price: price,
        title: name,
        optionSet: optionSet,
        item: itemData,
        index: index,
      );

      /// Add dashed border for first item
      if (index == 0) {
        itemWidget = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: DashedBorder.fromBorderSide(
              side: const BorderSide(color: Colors.black, width: 0.2),
              dashLength: 2.5,
              spaceLength: 2.5,
            ),
          ),
          child: itemWidget,
        );
      }

      widgets.add(itemWidget);
    }

    return widgets;
  }
}
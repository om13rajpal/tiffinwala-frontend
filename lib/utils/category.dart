import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/providers/veg.dart';
import 'package:tiffinwala/utils/text and inputs/itemdetails.dart';

final loadedItemCountProvider = StateProvider.family<int, String>((
  ref,
  categoryTitle,
) {
  return 10;
});

class Category extends ConsumerWidget {
  final String title;
  final List<dynamic> items;

  const Category({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVeg = ref.watch(isVegProvider);
    final isNonVeg = ref.watch(isNonVegProvider);
    final loadedItemCount = ref.watch(loadedItemCountProvider(title));

    final filteredItems = _filterItems(items, isVeg, isNonVeg);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 50 &&
            loadedItemCount < filteredItems.length) {
          ref
              .read(loadedItemCountProvider(title).notifier)
              .update((count) => (count + 10).clamp(0, filteredItems.length));
        }
        return false;
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: 1 + loadedItemCount.clamp(0, filteredItems.length),
        itemBuilder: (context, index) {
          if (index == 0) {
            /// The header goes here — inside the list!
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ClipRRect(
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
            );
          } else {
            /// Items start at index-1
            final item = filteredItems[index - 1];
            final itemData = item['item'];
            final optionSet = item['optionSet'];
            final price = itemData['price'];
            final name = itemData['itemName'];
            final description = itemData['description'] ?? "";

            Widget itemWidget = ItemDetails(
              isCartItem: false,
              description: description,
              price: price,
              title: name,
              optionSet: optionSet,
              item: itemData,
              index: index - 1,
            );

            if (index - 1 == 0) {
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

            return itemWidget;
          }
        },
      ),
    );
  }

  /// Helper to filter items based on veg selection
  List<Map<String, dynamic>> _filterItems(List<dynamic> items, bool isVeg, bool isNonVeg) {
    List<Map<String, dynamic>> filtered = [];

    for (final item in items) {
      final itemData = item['item'];
      if (itemData == null) continue;

      final price = itemData['price'];
      final name = itemData['itemName'];
      final tagIds = itemData['itemTagIds'] as List?;
      final status = itemData['status'];

      if (price == null || name == null) {
        continue;
      }

      // Exclude items not marked as Active
      if (status != "Active") {
        continue;
      }

      if (isVeg) {
        if (tagIds == null || tagIds.isEmpty) continue;
        if (tagIds[0] != Classification.veg) continue;
      }
      if (isNonVeg) {
        if (tagIds == null || tagIds.isEmpty) continue;
        if (tagIds[0] == Classification.veg) continue;
      }

      filtered.add(item);
    }

    return filtered;
  }
}

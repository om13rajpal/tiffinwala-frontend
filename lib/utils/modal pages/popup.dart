import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/screens/menu.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

WoltModalSheetPage menuPopUp(
  BuildContext context,
  List<dynamic> categories,
  List<dynamic> items,
  Function(int) scrollToCategory,
) {
  return WoltModalSheetPage(
    hasTopBarLayer: true,
    topBar: const Center(
      child: Text(
        'Menu',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    scrollController: ScrollController(),
    isTopBarLayerAlwaysVisible: true,
    useSafeArea: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: List.generate(categories.length, (index) {
          // 🔁 Lowercase category name
          final categoryName = categories[index]['name'].toString().toLowerCase();

          // 🚫 List of excluded categories
          final excluded = [
            'others',
            'indian main course',
            'chapatis',
            'beverage',
            'accompaniments',
          ];

          // 🚫 Skip rendering this category
          if (excluded.contains(categoryName)) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onTap: () {
              scrollToCategory(index);
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 10),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categories[index]['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        categoryItems[index].length.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  endIndent: 30,
                  indent: 30,
                  color: Color.fromARGB(255, 65, 65, 65),
                  thickness: 0.5,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ),
    ),
  );
}
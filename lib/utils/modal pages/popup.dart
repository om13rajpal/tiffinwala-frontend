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
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: List.generate(categories.length, (index) {
          return GestureDetector(
            onTap: () {
              scrollToCategory(index);
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  margin: EdgeInsets.only(bottom: 10),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categories[index]['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        categoryItems[index].length.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  endIndent: 30,
                  indent: 30,
                  color: Color.fromARGB(255, 65, 65, 65),
                  thickness: 0.5,
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        }),
      ),
    ),
  );
}

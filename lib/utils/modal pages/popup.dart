import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

WoltModalSheetPage menuPopUp(
  BuildContext context,
  List<dynamic> categories,
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
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              margin: EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 37, 37, 37),
              ),
              child: Text(
                categories[index]['name'],
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ),
    ),
  );
}
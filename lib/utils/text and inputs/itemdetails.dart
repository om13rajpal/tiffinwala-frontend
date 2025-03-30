import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ItemDetails extends StatelessWidget {
  final int price;
  final String title;
  final List<dynamic> optionSet;
  const ItemDetails({
    super.key,
    required this.price,
    required this.title,
    required this.optionSet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icons/veg.png', width: 11, fit: BoxFit.cover),
              SizedBox(width: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.5),
                  color: Color(0xFFF78080),
                ),
                child: Center(
                  child: Text(
                    'Best Seller',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB30000),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                height: 24,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF3E3E3E)),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 6),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  onPressed: () {
                    WoltModalSheet.show(
                      context: context,
                      pageListBuilder: (context) {
                        return [
                          addOns(
                            context,
                            Theme.of(context).textTheme,
                            optionSet,
                          ),
                        ];
                      },
                      modalTypeBuilder: (context) => WoltModalType.dialog(),
                    );
                  },
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            '₹ ${price.toString()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF787878),
            ),
          ),
        ],
      ),
    );
  }
}

WoltModalSheetPage addOns(
  BuildContext context,
  TextTheme textTheme,
  List<dynamic> optionSet,
) {
  return WoltModalSheetPage(
    topBar: const Center(
      child: Text(
        'Add-ons',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    isTopBarLayerAlwaysVisible: true,
    useSafeArea: true,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        spacing: 15,
        children: [
          ...optionSet.map((e) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e['name']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(e['options'].length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Text(
                                  e['options'][index]['optionName'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD2D2D2),
                                  ),
                                ),
                                Text(
                                  '₹ ${e['options'][index]['price']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF787878),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ],
                            ),
                            TiffinCheckbox(),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
          ElevatedButton(
            onPressed: () {
              WoltModalSheet.of(context).showPrevious();
            },
            child: Text('ADD'),
          ),
        ],
      ),
    ),
  );
}

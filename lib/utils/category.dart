import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';

class Category extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final VoidCallback updateUI;
  const Category({
    super.key,
    required this.title,
    required this.items,
    required this.updateUI,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(46),
              topRight: Radius.circular(46),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 12,
                left: 12,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Column(
          children: List.generate(items.length, (index) {
            if (items[index]['item']['price'] == null ||
                items[index]['item']['itemName'] == null) {
              return Container();
            }

            if (Veg.isVeg) {
              if (items[index]['item']['itemTagIds'][0] == Classification.veg) {
                if (index == 0) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: DashedBorder.fromBorderSide(
                        side: BorderSide(color: Colors.black, width: 0.2),
                        dashLength: 2.5,
                        spaceLength: 2.5,
                      ),
                    ),
                    child: ItemDetails(
                      price: items[index]['item']['price'],
                      title: items[index]['item']['itemName'],
                      optionSet: items[index]['optionSet'],
                      item: items[index]['item'],
                      onTap: updateUI,
                      index: index,
                    ),
                  );
                }
                return ItemDetails(
                  price: items[index]['item']['price'],
                  title: items[index]['item']['itemName'],
                  optionSet: items[index]['optionSet'],
                  item: items[index]['item'],
                  onTap: updateUI,
                  index: index,
                );
              }
            } else {
              if (index == 0) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: DashedBorder.fromBorderSide(
                      side: BorderSide(color: Colors.black, width: 0.2),
                      dashLength: 2.5,
                      spaceLength: 2.5,
                    ),
                  ),
                  child: ItemDetails(
                    price: items[index]['item']['price'],
                    title: items[index]['item']['itemName'],
                    optionSet: items[index]['optionSet'],
                    item: items[index]['item'],
                    onTap: updateUI,
                    index: index,
                  ),
                );
              }
              return ItemDetails(
                price: items[index]['item']['price'],
                title: items[index]['item']['itemName'],
                optionSet: items[index]['optionSet'],
                item: items[index]['item'],
                onTap: updateUI,
                index: index,
              );
            }

            return Container();
          }),
        ),
      ],
    );
  }
}

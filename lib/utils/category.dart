import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';

class Category extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  const Category({super.key, required this.title, required this.items});

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
            if (items[index]['price'] == null ||
                items[index]['itemName'] == null) {
              return Container();
            }

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
                  price: items[index]['price'],
                  title: items[index]['itemName'],
                ),
              );
            }
            return ItemDetails(
              price: items[index]['price'],
              title: items[index]['itemName'],
            );
          }),
        ),
      ],
    );
  }
}

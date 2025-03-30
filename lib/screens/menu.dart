import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:tiffinwala/constants/colors/url.dart';
import 'package:tiffinwala/utils/category.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/carousel.dart';
import 'package:tiffinwala/utils/coupen.dart';
import 'package:tiffinwala/utils/menucontrols.dart';
import 'package:http/http.dart' as http;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

List<dynamic> categories = [];
List<dynamic> items = [];
List<dynamic> optionSets = [];
List<dynamic> categoryItems = [];
List<dynamic> optionSetItemWise = [];

List<dynamic> menu = [];

class _MenuState extends State<Menu> {
  Future<void> getMenu() async {
    var response = await http.get(
      Uri.parse('${BaseUrl.url}/menu'),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = await jsonDecode(response.body);

    if (jsonRes['status']) {
      categories = jsonRes['data']['categories'];
      items = jsonRes['data']['items'];
      optionSets = jsonRes['data']['optionSets'];

      for (var item in items) {
        List<dynamic> optionSetItems = [];
        if (item['optionSetIds'] != null) {
          for (var optionSetId in item['optionSetIds']) {
            var optionSetItem = optionSets.firstWhere(
              (element) => element['optionSetId'] == optionSetId,
            );
            optionSetItems.add(optionSetItem);
          }
        }
        optionSetItemWise.add(optionSetItems.isNotEmpty ? optionSetItems : []);
      }

      for (var i = 0; i < items.length; i++) {
        var newItem = {'item': items[i], 'optionSet': optionSetItemWise[i]};
        menu.add(newItem);
      }

      for (var category in categories) {
        List itemCategory =
            menu
                .where(
                  (element) =>
                      element['item']['categoryId'] == category['categoryId'],
                )
                .toList();
        categoryItems.add(itemCategory);
      }
      categories = categories.reversed.toList();
      categoryItems = categoryItems.reversed.toList();

      setState(() {});
    } else {
      log(jsonRes['message']);
    }
  }

  @override
  void initState() {
    getMenu();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            TiffinAppBar(),
            SliverToBoxAdapter(child: Address()),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: MenuControls()),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: PosterCarousel()),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: CouponCode()),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: AnimatedContainer(
                margin: EdgeInsets.symmetric(horizontal: 3),
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: Column(
                    children: List.generate(categories.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Category(
                          title: categories[index]['name'],
                          items: categoryItems[index],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

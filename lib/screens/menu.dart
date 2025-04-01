import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tiffinwala/constants/cart.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
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

bool showCart = false;

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

  void updateUI() {
    setState(() {
      if (Cart.cart.isNotEmpty) {
        showCart = true;
      } else {
        showCart = false;
      }
    });
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
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  TiffinAppBar(onTap: updateUI),
                  SliverToBoxAdapter(child: Address()),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: MenuControls()),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: PosterCarousel()),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: CouponCode()),
                  SliverToBoxAdapter(child: SizedBox(height: 5)),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Category(
                                        title: categories[index]['name'],
                                        items: categoryItems[index],
                                        updateUI: updateUI,
                                      )
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 5)),
                ],
              ),
            ),
            Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Visibility(
                    visible: showCart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(250),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            spacing: 2,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${Cart.cart.length} items in cart',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                '₹ ${Cart.totalPrice}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          TiffinButton(
                            label: 'CART',
                            width: 50,
                            height: 24,
                            onPressed: () => log('cart'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .animate(key: ValueKey(showCart))
                .slideY(
                  begin: 1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
          ],
        ),
      ),
    );
  }
}

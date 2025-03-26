import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:tiffinwala/constants/colors/url.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/carousel.dart';
import 'package:tiffinwala/utils/coupen.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';
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

    for (var category in categories) {
      log(category['name']);
      List categoryItems =
          items
              .where(
                (element) => element['categoryId'] == category['categoryId'],
              )
              .toList();
      log(categoryItems.toString());
    }
  } else {
    log(jsonRes['message']);
  }
}

class _MenuState extends State<Menu> {
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
                height: 300,
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
                                'Tiffin Biryani',
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: DashedBorder.fromBorderSide(
                            side: BorderSide(color: Colors.black, width: 0.2),
                            dashLength: 2.5,
                            spaceLength: 2.5,
                          ),
                        ),
                        child: ItemDetails(),
                      ),
                    ],
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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
import 'package:tiffinwala/utils/carousel.dart';
import 'package:tiffinwala/utils/dropdown.dart';
import 'package:tiffinwala/utils/switch.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

bool value = false;

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              actionsPadding: EdgeInsets.symmetric(horizontal: 10),
              titleSpacing: 20,
              title: Text(
                'Tiffinwala',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.icon,
                  fontWeight: FontWeight.w500,
                ),
              ),
              floating: true,
              pinned: false,
              snap: false,
              backgroundColor: AppColors.primary,
              forceMaterialTransparency: true,
              actions: [
                IconButton(
                  onPressed: () => log("search"),
                  icon: LucideIconWidget(
                    icon: LucideIcons.search,
                    size: 13,
                    color: AppColors.icon,
                    strokeWidth: 2,
                  ),
                ),
                IconButton(
                  onPressed: () => log("profile"),
                  icon: LucideIconWidget(
                    icon: LucideIcons.userRound,
                    size: 13,
                    color: AppColors.icon,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LucideIconWidget(
                      icon: LucideIcons.map,
                      strokeWidth: 2,
                      color: AppColors.icon,
                      size: 14,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'House no. 381, Sector 16, near Indus Public School, Hisar, Haryana, 125001',
                        style: TextStyle(
                          fontSize: 11,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.icon,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 105, child: CustomDrowdpwn()),
                    SizedBox(width: 25),
                    Text(
                      'Veg only',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.icon,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 5),
                    VegOnlySwitch(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: PosterCarousel()),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF40C9),
                      Color(0xFFFF0099),
                      Color(0xFFF7BB97),
                    ],
                    stops: [0.0, 0.3, 1.0],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: -1,
                      child: LucideIconWidget(
                        icon: LucideIcons.ticketPercent,
                        size: 35,
                        strokeWidth: 1,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Flat',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text: ' 10% ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'off on orders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'above ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text: '₹499.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' Use Coupon',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text: ' TIFFIN10',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        log("copy");
                      },
                      icon: LucideIconWidget(icon: LucideIcons.copy, size: 15),
                    ),
                  ],
                ),
              ),
            ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: DashedBorder.fromBorderSide(side: BorderSide(
                            color: Colors.black,
                            width: 0.2,
                          ), dashLength: 2.5, spaceLength: 2.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LucideIconWidget(
                                  icon: LucideIcons.vegan,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 5),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 0.5,
                                  ),
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
                                    'Veg Biryani with Raita & Salad',
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
                                      backgroundColor: WidgetStatePropertyAll(
                                        Color(0xFF3E3E3E),
                                      ),
                                      padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(horizontal: 6),
                                      ),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
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
                              '₹ 79',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF787878),
                              ),
                            ),
                          ],
                        ),
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

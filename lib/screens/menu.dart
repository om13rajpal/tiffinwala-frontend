import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors/colors.dart';
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
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 105,
                      child: CustomDrowdpwn()),
                    SizedBox(width: 25),
                    Text(
                      'Veg only',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.icon,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 5,),
                    VegOnlySwitch()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

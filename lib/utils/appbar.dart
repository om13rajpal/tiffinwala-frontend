import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors/colors.dart';

class TiffinAppBar extends StatelessWidget {
  const TiffinAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
    );
  }
}

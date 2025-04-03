import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';

class Address extends StatelessWidget {
  const Address({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

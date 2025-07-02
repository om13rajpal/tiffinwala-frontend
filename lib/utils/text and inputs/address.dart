import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/screens/address.dart';

class Address extends StatelessWidget {
  final String address;
  const Address({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddressPage()),
          ),
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
              address,
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

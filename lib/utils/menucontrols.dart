import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/utils/buttons/dropdown.dart';
import 'package:tiffinwala/utils/buttons/switch.dart';

class MenuControls extends StatelessWidget {
  const MenuControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 110, child: CustomDrowdpwn()),
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
    );
  }
}

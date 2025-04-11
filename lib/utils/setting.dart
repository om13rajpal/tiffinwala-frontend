import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Setting extends StatelessWidget {
  final int index;
  final String label;
  const Setting({super.key, required this.index, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 40),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border:
                  (index != 3)
                      ? Border(bottom: BorderSide(color: Color(0xff464646)))
                      : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE2E2E2),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: LucideIconWidget(
                    icon: LucideIcons.chevronRight,
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

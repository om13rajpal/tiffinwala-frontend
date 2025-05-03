import 'package:flutter/material.dart' as material;
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class Setting extends StatelessWidget {
  final int index;
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Color bgcolor;
  const Setting({
    super.key,
    required this.index,
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.bgcolor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgcolor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: lucide.LucideIconWidget(icon: icon, size: 14),
            ),
          ),
          SizedBox(width: 20),
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
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE2E2E2),
                    ),
                  ),
                  material.Icon(LucideIcons.chevronRight, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

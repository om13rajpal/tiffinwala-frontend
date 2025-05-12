import 'package:flutter/material.dart' as material;
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide_flutter;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/screens/profile.dart';

class TiffinAppBar extends StatefulWidget {
  final bool centerTitle;
  final String title;
  const TiffinAppBar({
    super.key,
    required this.centerTitle,
    required this.title,
  });

  @override
  State<TiffinAppBar> createState() => _TiffinAppBarState();
}

class _TiffinAppBarState extends State<TiffinAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      leadingWidth: (widget.centerTitle) ? 38 : 0,
      leading:
          (widget.centerTitle)
              ? material.Padding(
                padding: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: lucide_flutter.LucideIconWidget(
                    icon: lucide_flutter.LucideIcons.arrowUpLeft,
                    color: AppColors.icon,
                  ),
                ),
              )
              : null,
      centerTitle: widget.centerTitle,
      elevation: 0,
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      titleSpacing: 20,
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.icon,
          fontWeight: FontWeight.w500,
        ),
      ),
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: AppColors.primary,
      forceMaterialTransparency: true,
      actions:
          (widget.centerTitle)
              ? null
              : [
                material.IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  },
                  icon: lucide_flutter.LucideIconWidget(
                    icon: lucide_flutter.LucideIcons.userRound,
                    size: 13,
                    color: AppColors.icon,
                  ),
                ),
              ],
    );
  }
}

import 'package:flutter/material.dart' as material;
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide_flutter;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/screens/auth.dart';

class TiffinAppBar extends StatefulWidget {
  const TiffinAppBar({super.key});

  @override
  State<TiffinAppBar> createState() => _TiffinAppBarState();
}

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
  if (!context.mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Auth()),
  );
}

class _TiffinAppBarState extends State<TiffinAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
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
        material.IconButton(
          onPressed: () {
            logout(context);
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

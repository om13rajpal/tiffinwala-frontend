import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide_flutter;
import 'package:tiffinwala/constants/colors.dart';

Widget buildToast(BuildContext context, ToastOverlay overlay, String toast) {
  return SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Basic(
      leading: const lucide_flutter.LucideIconWidget(
        icon: lucide_flutter.LucideIcons.circleCheck,
        size: 16,
        color: AppColors.secondary,
        strokeWidth: 2,
      ),
      leadingAlignment: Alignment.center,
      title: Text(
        toast,
        style: TextStyle(fontSize: 12.5),
      ),
    ),
  );
}

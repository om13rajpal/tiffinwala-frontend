import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide_flutter;
import 'package:tiffinwala/constants/colors/colors.dart';

Widget buildToast(BuildContext context, ToastOverlay overlay) {
  return SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Basic(
      leading: const lucide_flutter.LucideIconWidget(
        icon: lucide_flutter.LucideIcons.circleCheck,
        size: 16,
        color: AppColors.secondary,
        strokeWidth: 2,
      ),
      leadingAlignment: Alignment.center,
      title: const Text(
        'User logged in successfully ;)',
        style: TextStyle(fontSize: 12.5),
      ),
      subtitle: Text(
        DateTime.now().toString(),
        style: TextStyle(fontSize: 10.5),
      ),
    ),
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/providers/veg.dart';

class VegOnlySwitch extends ConsumerStatefulWidget {
  final VoidCallback updateUI;
  const VegOnlySwitch({super.key, required this.updateUI});

  @override
  ConsumerState<VegOnlySwitch> createState() => _VegOnlySwitchState();
}

class _VegOnlySwitchState extends ConsumerState<VegOnlySwitch> {
  @override
  Widget build(BuildContext context) {
    final isVeg = ref.watch(isVegProvider);

    return Switch(
      value: isVeg,
      onChanged: (v) => ref.read(isVegProvider.notifier).setVeg(v),
    );
  }
}

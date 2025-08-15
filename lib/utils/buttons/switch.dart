import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/providers/veg.dart';

class VegOnlySwitch extends ConsumerStatefulWidget {
  const VegOnlySwitch({super.key});

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

class NonVegOnlySwitch extends ConsumerStatefulWidget {
  const NonVegOnlySwitch({super.key});

  @override
  ConsumerState<NonVegOnlySwitch> createState() => _NonVegOnlySwitchState();
}

class _NonVegOnlySwitchState extends ConsumerState<NonVegOnlySwitch> {
  @override
  Widget build(BuildContext context) {
    final isNonVeg = ref.watch(isNonVegProvider);

    return Switch(
      value: isNonVeg,
      onChanged: (v) => ref.read(isNonVegProvider.notifier).setNonVeg(v),
    );
  }
}

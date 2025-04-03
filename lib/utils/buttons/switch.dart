import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/constants/veg.dart';

class VegOnlySwitch extends StatefulWidget {
  const VegOnlySwitch({super.key});

  @override
  State<VegOnlySwitch> createState() => _VegOnlySwitchState();
}

bool value = false;

class _VegOnlySwitchState extends State<VegOnlySwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged:
          (v) => setState(() {
            value = v;
            Veg.isVeg = v;
            print(Veg.isVeg);
          }),
    );
  }
}

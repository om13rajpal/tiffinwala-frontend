import 'package:shadcn_flutter/shadcn_flutter.dart';

class TiffinCheckbox extends StatefulWidget {
  const TiffinCheckbox({super.key});

  @override
  State<TiffinCheckbox> createState() => _TiffinCheckboxState();
}

class _TiffinCheckboxState extends State<TiffinCheckbox> {
  CheckboxState _state = CheckboxState.unchecked;
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      state: _state,
      onChanged: (value) {
        setState(() {
          _state = value;
        });
      },
    );
  }
}

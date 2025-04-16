import 'package:shadcn_flutter/shadcn_flutter.dart';

class TiffinCheckbox extends StatefulWidget {
  final bool preChecked;
  final Function(bool) onChanged;
  const TiffinCheckbox({
    super.key,
    required this.preChecked,
    required this.onChanged,
  });

  @override
  State<TiffinCheckbox> createState() => _TiffinCheckboxState();
}

class _TiffinCheckboxState extends State<TiffinCheckbox> {
  late CheckboxState _state;
  @override
  void initState() {
    super.initState();
    if (widget.preChecked) {
      _state = CheckboxState.checked;
    } else {
      _state = CheckboxState.unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      state: _state,
      onChanged: (value) {
        setState(() {
          _state = value;
        });
        widget.onChanged(_state == CheckboxState.checked ? true : false);
      },
    );
  }
}

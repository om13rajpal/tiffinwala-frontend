import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/providers/ordermode.dart';

class CustomDrowdpwn extends ConsumerStatefulWidget {
  const CustomDrowdpwn({super.key});

  @override
  ConsumerState<CustomDrowdpwn> createState() => _DrowdpwnState();
}

final List<String> dropDown = ['Delivery', 'Pickup'];

class _DrowdpwnState extends ConsumerState<CustomDrowdpwn> {
  @override
  Widget build(BuildContext context) {
    String? selectedValue = ref.watch(setOrderModeProvider);

    return Select<String>(
      itemBuilder: (context, item) {
        return Text(item, style: const TextStyle(fontSize: 10));
      },
      popupConstraints: const BoxConstraints(maxHeight: 300, maxWidth: 200),
      onChanged: (value) {
        ref.read(setOrderModeProvider.notifier).setOrderMode(value!);
      },
      value: selectedValue,
      popup:
          SelectPopup(
            items: SelectItemList(
              children:
                  dropDown
                      .map(
                        (e) => SelectItemButton(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 12.5)),
                        ),
                      )
                      .toList(),
            ),
          ).call,
    );
  }
}

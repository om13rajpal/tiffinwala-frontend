import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomDrowdpwn extends StatefulWidget {
  const CustomDrowdpwn({super.key});

  @override
  State<CustomDrowdpwn> createState() => _DrowdpwnState();
}

final List<String> dropDown = ['Delivery', 'Pickup'];
String? selectedValue = dropDown[0];

class _DrowdpwnState extends State<CustomDrowdpwn> {
  @override
  Widget build(BuildContext context) {
    return Select<String>(
      itemBuilder: (context, item) {
        return Text(item, style: const TextStyle(fontSize: 10));
      },
      popupConstraints: const BoxConstraints(maxHeight: 300, maxWidth: 200),
      onChanged: (value) {
        setState(() {
          selectedValue = value;
        });
      },
      value: selectedValue,
      popup:
          SelectPopup(
            items: SelectItemList(
              children:
                  dropDown
                      .map((e) => SelectItemButton(value: e, child: Text(e, style: const TextStyle(fontSize: 10))))
                      .toList(),
            ),
          ).call,
    );
  }
}

import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide;

class ItemDetails extends ConsumerStatefulWidget {
  final int price;
  final String title;
  final dynamic item;
  final List<dynamic> optionSet;
  final int index;
  final bool isCartItem;
  const ItemDetails({
    super.key,
    required this.price,
    required this.title,
    required this.optionSet,
    required this.item,
    required this.index,
    required this.isCartItem,
  });

  @override
  ConsumerState<ItemDetails> createState() => _ItemDetailsState();
}

List<dynamic> selectedOptions = [];

void handleCheckbox(dynamic option, bool isChecked) {
  if (isChecked) {
    selectedOptions.add(option);
  } else {
    selectedOptions.remove(option);
  }
}

class _ItemDetailsState extends ConsumerState<ItemDetails> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final counter =
        cart
            .firstWhere(
              (item) => item.item['itemName'] == widget.item['itemName'],
              orElse: () => CartItems(widget.item, 0.0, [], 0),
            )
            .quantity;
    final itemExists = counter > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (widget.item['itemTagIds'][0] == Classification.veg)
                  ? Image.asset(
                    'assets/icons/veg.png',
                    width: 11,
                    fit: BoxFit.cover,
                  )
                  : Image.asset(
                    'assets/icons/nonveg.png',
                    width: 11,
                    fit: BoxFit.cover,
                  ),
              SizedBox(width: 5),
              (widget.index == 0)
                  ? Container(
                    padding: EdgeInsets.only(
                      left: 6,
                      top: 1.5,
                      bottom: 2.5,
                      right: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0xFFF78080),
                    ),
                    child: Center(
                      child:
                          (widget.index == 0)
                              ? Text(
                                'Best Seller',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB30000),
                                  height: 0,
                                ),
                              )
                              : null,
                    ),
                  )
                  : Container(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color:
                        (widget.isCartItem)
                            ? AppColors.secondary
                            : AppColors.primary,
                  ),
                ),
              ),
              (itemExists)
                  ? Container(
                    width: 65,
                    height: 28,
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF3E3E3E),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 5,
                      children: [
                        GestureDetector(
                          onTap:
                              () => ref
                                  .read(cartProvider.notifier)
                                  .decrementCart(widget.item),
                          child: lucide.LucideIconWidget(
                            icon: LucideIcons.minus,
                            size: 13,
                          ),
                        ),
                        Text(
                          '$counter',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              () => ref
                                  .read(cartProvider.notifier)
                                  .incrementCart(widget.item),
                          child: lucide.LucideIconWidget(
                            icon: LucideIcons.plus,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                  : SizedBox(
                    width: 65,
                    height: 28,
                    child: material.ElevatedButton(
                      style: material.ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xFF3E3E3E),
                        ),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 6),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      onPressed: () {
                        selectedOptions.clear();
                        WoltModalSheet.show(
                          context: context,
                          pageListBuilder: (context) {
                            return [
                              addOns(
                                context,
                                widget.optionSet,
                                widget.item,
                                ref,
                              ),
                            ];
                          },
                          modalTypeBuilder: (context) => WoltModalType.dialog(),
                        );
                      },
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          Text(
            '₹ ${widget.price.toString()}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF787878),
            ),
          ),
        ],
      ),
    );
  }
}

WoltModalSheetPage addOns(
  BuildContext context,
  List<dynamic> optionSet,
  dynamic item,
  WidgetRef ref,
) {
  return WoltModalSheetPage(
    hasSabGradient: false,
    hasTopBarLayer: true,
    topBar: const Center(
      child: Text(
        'Add-ons',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    scrollController: ScrollController(),
    isTopBarLayerAlwaysVisible: true,
    stickyActionBar: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TiffinButton(
        label: 'ADD TO CART',
        width: 120,
        height: 30,
        onPressed: () {
          var itemPrice = item['price'].toDouble();
          for (var option in selectedOptions) {
            itemPrice += option['price'].toDouble();
          }

          ref
              .read(cartProvider.notifier)
              .addItem(item, itemPrice, selectedOptions, 1);
          Navigator.pop(context);
        },
      ),
    ),
    useSafeArea: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        spacing: 15,
        children: [
          ...optionSet.asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientText(text: e['name']),
                  const SizedBox(height: 17),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(e['options'].length, (i) {
                      final opt = e['options'][i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              opt['optionName'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFD2D2D2),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  opt['price'] == 0
                                      ? ''
                                      : '+ ₹${opt['price']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF787878),
                                  ),
                                ),
                                TiffinCheckbox(
                                  preChecked: opt['price'] == 0,
                                  onChanged: (isChecked) {
                                    handleCheckbox(opt, isChecked);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  if (idx != optionSet.length - 1)
                    const Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 0.5,
                      color: Color.fromARGB(255, 65, 65, 65),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 15),
        ],
      ),
    ),
  );
}
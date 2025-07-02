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
      padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              material.Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemType(widget: widget),
                  SizedBox(height: 4),
                  itemTitle(),
                  SizedBox(height: 5),
                  price(),
                  SizedBox(height: 6),

                  material.SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      maxLines: 2,
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elitSed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const material.Color.fromARGB(255, 74, 74, 74),
                      ),
                    ),
                  ),
                ],
              ),
              material.Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.gray,
                      width: 110,
                      height: 110,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(0, 10),
                      child: Container(
                        child:
                            (itemExists)
                                ? material.Center(child: countButton(counter))
                                : material.Center(child: addButton(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  material.Text price() {
    return Text(
      '₹ ${widget.price.toString()}',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: material.Color.fromARGB(255, 22, 22, 22),
      ),
    );
  }

  material.SizedBox addButton(material.BuildContext context) {
    return SizedBox(
      width: 80,
      height: 35,
      child: material.ElevatedButton(
        style: material.ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xFF3E3E3E)),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: () {
          selectedOptions.clear();
          WoltModalSheet.show(
            context: context,
            pageListBuilder: (context) {
              return [addOns(context, widget.optionSet, widget.item, ref)];
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
    );
  }

  material.Container countButton(int counter) {
    return Container(
      width: 80,
      height: 35,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF3E3E3E),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 5,
        children: [
          GestureDetector(
            onTap:
                () =>
                    ref.read(cartProvider.notifier).decrementCart(widget.item),
            child: lucide.LucideIconWidget(icon: LucideIcons.minus, size: 13),
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
                () =>
                    ref.read(cartProvider.notifier).incrementCart(widget.item),
            child: lucide.LucideIconWidget(icon: LucideIcons.plus, size: 13),
          ),
        ],
      ),
    );
  }

  material.SizedBox itemTitle() {
    return SizedBox(
      width: 150,
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: (widget.isCartItem) ? AppColors.secondary : AppColors.primary,
        ),
      ),
    );
  }
}

class ItemType extends material.StatelessWidget {
  const ItemType({super.key, required this.widget});

  final ItemDetails widget;

  @override
  material.Widget build(material.BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (widget.item['itemTagIds'][0] == Classification.veg)
            ? Image.asset('assets/icons/veg.png', width: 13, fit: BoxFit.cover)
            : Image.asset(
              'assets/icons/nonveg.png',
              width: 13,
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
                            fontSize: 9.5,
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
                                  opt['price'] == 0 ? '' : '+ ₹${opt['price']}',
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

import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';
import 'package:tiffinwala/utils/text and inputs/gradientext.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide;

class ItemDetails extends ConsumerStatefulWidget {
  final CartItems? cartItem;
  final dynamic item;
  final int? price;
  final String? title;
  final List<dynamic> optionSet;
  final int index;
  final bool isCartItem;
  final String? description;
  final String? imageUrl;

  const ItemDetails({
    super.key,
    this.description,
    this.cartItem,
    this.item,
    this.price,
    this.title,
    this.imageUrl,
    required this.optionSet,
    required this.index,
    required this.isCartItem,
  });

  @override
  ConsumerState<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends ConsumerState<ItemDetails> {
  List<dynamic> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.isCartItem) {
      _selectedOptions = [];
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    final isCart = widget.isCartItem;

    final item = isCart ? widget.cartItem!.item : widget.item;
    final price =
        isCart ? widget.cartItem!.totalPrice : widget.price?.toDouble() ?? 0.0;
    final title =
        isCart ? widget.cartItem!.item['itemName'] : widget.title ?? '';
    final options = isCart ? widget.cartItem!.options : _selectedOptions;

    final cart = ref.watch(cartProvider);

    final existingCartItem =
        cart.any(
              (cartItem) =>
                  cartItem.item['itemName'] == widget.item?['itemName'] &&
                  _compareOptions(cartItem.options, _selectedOptions),
            )
            ? cart.firstWhere(
              (cartItem) =>
                  cartItem.item['itemName'] == widget.item?['itemName'] &&
                  _compareOptions(cartItem.options, _selectedOptions),
            )
            : null;

    final counter =
        isCart
            ? widget.cartItem?.quantity ?? 0
            : (existingCartItem?.quantity ?? 0);

    final itemExists = counter > 0;

    /// ✅ CART VIEW
    if (isCart) {
      return material.Container(
        padding: const material.EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        child: material.Row(
          mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
          children: [
            material.Column(
              crossAxisAlignment: material.CrossAxisAlignment.start,
              children: [
                ItemType(item: item, index: widget.index),
                const material.SizedBox(height: 4),
                itemTitle(title),
                const material.SizedBox(height: 5),
                priceText(price),
              ],
            ),
            itemExists
                ? countButton(counter, item, options)
                : addButton(context, item, price),
          ],
        ),
      );
    }

    /// ✅ FULL NORMAL ITEM VIEW
    return material.Container(
      padding: const material.EdgeInsets.only(
        left: 10,
        right: 10,
        top: 7,
        bottom: 20,
      ),
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          material.Row(
            mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  ItemType(item: item, index: widget.index),
                  const material.SizedBox(height: 4),
                  itemTitle(title),
                  const material.SizedBox(height: 5),
                  priceText(price),
                  const material.SizedBox(height: 6),
                  material.SizedBox(
                    width: material.MediaQuery.of(context).size.width * 0.5,
                    child: material.Text(
                      widget.description ?? "",
                      maxLines: 2,
                      overflow: material.TextOverflow.ellipsis,
                      style: const material.TextStyle(
                        fontSize: 11.5,
                        fontWeight: material.FontWeight.w500,
                        color: material.Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                ],
              ),
              material.Stack(
                children: [
                  material.ClipRRect(
                    borderRadius: material.BorderRadius.circular(12),
                    child:
                        widget.imageUrl != null &&
                                widget.imageUrl.toString().isNotEmpty
                            ? material.Image.network(
                              widget.imageUrl!,
                              width: 110,
                              height: 110,
                              fit: material.BoxFit.cover,
                            )
                            : material.Container(
                              color: material.Colors.grey,
                              width: 110,
                              height: 110,
                            ),
                  ),
                  material.Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: material.Transform.translate(
                      offset: const material.Offset(0, 10),
                      child:
                          itemExists
                              ? material.Center(
                                child: countButton(counter, item, options),
                              )
                              : material.Center(
                                child: addButton(context, item, price),
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

  material.Text priceText(double price) {
    return material.Text(
      '₹ ${price.toString()}',
      style: material.TextStyle(
        fontSize: 12,
        fontWeight: material.FontWeight.w500,
        color:
            widget.isCartItem
                ? const material.Color(0xFFEFEFEF)
                : const material.Color(0xFF161616),
      ),
    );
  }

  material.SizedBox addButton(
    material.BuildContext context,
    dynamic item,
    double price,
  ) {
    return material.SizedBox(
      width: 80,
      height: 35,
      child: material.ElevatedButton(
        style: material.ButtonStyle(
          backgroundColor: const material.WidgetStatePropertyAll(
            material.Color(0xFF3E3E3E),
          ),
          shape: material.WidgetStatePropertyAll(
            material.RoundedRectangleBorder(
              borderRadius: material.BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: () {
          openAddOns(context, item, price);
        },
        child: material.Text(
          'ADD',
          style: material.TextStyle(
            fontSize: 10,
            fontWeight: material.FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  material.Container countButton(
    int counter,
    dynamic item,
    List<dynamic> options,
  ) {
    return material.Container(
      width: 80,
      height: 35,
      padding: const material.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: material.BoxDecoration(
        borderRadius: material.BorderRadius.circular(10),
        color: const material.Color(0xFF3E3E3E),
      ),
      child: material.Row(
        mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
        children: [
          material.GestureDetector(
            onTap: () {
              if (widget.isCartItem) {
                ref
                    .read(cartProvider.notifier)
                    .decrementCart(
                      widget.cartItem!.item,
                      widget.cartItem!.options,
                    );
              } else {
                ref
                    .read(cartProvider.notifier)
                    .decrementCart(widget.item, _selectedOptions);
              }
            },
            child: lucide.LucideIconWidget(
              icon: lucide.LucideIcons.minus,
              size: 13,
            ),
          ),
          material.Text(
            '$counter',
            style: material.TextStyle(
              fontSize: 12,
              fontWeight: material.FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          material.GestureDetector(
            onTap: () => showIncrementDialog(context, item, options),
            child: lucide.LucideIconWidget(
              icon: lucide.LucideIcons.plus,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }

  material.SizedBox itemTitle(String title) {
    return material.SizedBox(
      width: 150,
      child: material.Text(
        title,
        style: material.TextStyle(
          fontSize: 13,
          fontWeight: material.FontWeight.w600,
          color: widget.isCartItem ? AppColors.secondary : AppColors.primary,
        ),
      ),
    );
  }

  void showIncrementDialog(
    material.BuildContext context,
    dynamic item,
    List<dynamic> options,
  ) {
    material.showDialog(
      context: context,
      builder:
          (context) => material.AlertDialog(
            title: const material.Text(
              'Choose Action',
              style: material.TextStyle(
                fontSize: 14,
                fontWeight: material.FontWeight.bold,
              ),
            ),
            content: const material.Text(
              'Would you like to add the same item again with existing customization or choose new customizations?',
              style: material.TextStyle(fontSize: 12),
            ),
            actions: [
              material.TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.isCartItem) {
                    ref
                        .read(cartProvider.notifier)
                        .incrementCart(
                          widget.cartItem!.item,
                          widget.cartItem!.options,
                        );
                  } else {
                    ref
                        .read(cartProvider.notifier)
                        .incrementCart(widget.item, _selectedOptions);
                  }
                },
                child: const material.Text(
                  'Existing Customization',
                  style: material.TextStyle(
                    color: material.Color.fromARGB(255, 218, 218, 218),
                    fontWeight: material.FontWeight.w600,
                  ),
                ),
              ),
              material.TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAddOns(context, item, widget.price?.toDouble() ?? 0.0);
                },
                child: const material.Text(
                  'New Customization',
                  style: material.TextStyle(
                    color: material.Color.fromARGB(255, 218, 218, 218),
                    fontWeight: material.FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void openAddOns(
    material.BuildContext context,
    dynamic item,
    double basePrice,
  ) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) {
        return [
          addOns(
            context,
            widget.optionSet,
            item,
            ref,
            preselectedOptions:
                widget.isCartItem ? widget.cartItem?.options : null,
            onConfirm: (newOptions) {
              setState(() {
                _selectedOptions = List.from(newOptions);
              });
            },
          ),
        ];
      },
      modalTypeBuilder: (context) => WoltModalType.dialog(),
    );
  }

  bool _compareOptions(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (final opt in a) {
      if (!b.any(
        (o) =>
            o['optionName'] == opt['optionName'] && o['price'] == opt['price'],
      )) {
        return false;
      }
    }
    return true;
  }
}

class ItemType extends material.StatelessWidget {
  final dynamic item;
  final int index;

  const ItemType({super.key, required this.item, required this.index});

  @override
  material.Widget build(material.BuildContext context) {
    return material.Row(
      children: [
        item['itemTagIds'][0] == Classification.veg
            ? material.Image.asset('assets/icons/veg.png', width: 13)
            : material.Image.asset('assets/icons/nonveg.png', width: 13),
        const material.SizedBox(width: 5),
        index == 0
            ? material.Container(
              padding: const material.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1.5,
              ),
              decoration: material.BoxDecoration(
                borderRadius: material.BorderRadius.circular(5),
                color: const material.Color(0xFFF78080),
              ),
              child: const material.Text(
                'Best Seller',
                style: material.TextStyle(
                  fontSize: 9.5,
                  fontWeight: material.FontWeight.w700,
                  color: material.Color(0xFFB30000),
                ),
              ),
            )
            : material.Container(),
      ],
    );
  }
}

WoltModalSheetPage addOns(
  material.BuildContext context,
  List<dynamic> optionSet,
  dynamic item,
  WidgetRef ref, {
  List<dynamic>? preselectedOptions,
  required void Function(List<dynamic>) onConfirm,
}) {
  List<dynamic> localSelectedOptions =
      preselectedOptions != null ? List.from(preselectedOptions) : [];

  void handleCheckbox(dynamic option, bool isChecked) {
    if (isChecked) {
      if (!localSelectedOptions.any(
        (o) =>
            o['optionName'] == option['optionName'] &&
            o['price'] == option['price'],
      )) {
        localSelectedOptions.add(option);
      }
    } else {
      localSelectedOptions.removeWhere(
        (o) =>
            o['optionName'] == option['optionName'] &&
            o['price'] == option['price'],
      );
    }
  }

  return WoltModalSheetPage(
    hasSabGradient: false,
    hasTopBarLayer: true,
    topBar: const material.Center(
      child: material.Text(
        'Add-ons',
        style: material.TextStyle(
          fontSize: 13,
          fontWeight: material.FontWeight.w600,
          color: material.Colors.white,
        ),
      ),
    ),
    stickyActionBar: material.Padding(
      padding: const material.EdgeInsets.only(bottom: 12),
      child: TiffinButton(
        label: 'ADD TO CART',
        width: 120,
        height: 30,
        onPressed: () {
          var itemPrice = (item['price']?.toDouble()) ?? 0.0;
          for (var option in localSelectedOptions) {
            itemPrice += (option['price']?.toDouble() ?? 0.0);
          }

          ref
              .read(cartProvider.notifier)
              .addItem(
                item,
                itemPrice,
                List.from(localSelectedOptions),
                1,
                optionSet,
              );
          Navigator.pop(context);
          onConfirm(localSelectedOptions);
        },
      ),
    ),
    useSafeArea: true,
    child: material.Padding(
      padding: const material.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: material.Column(
        children: [
          material.Text(
            'Add ons',
            style: const material.TextStyle(
              fontSize: 17,
              fontWeight: material.FontWeight.w600,
            ),
          ),
          ...optionSet.asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value ?? {};
            final name = e['name'] ?? '';
            final optionsList = e['options'] ?? [];

            return material.Container(
              padding: const material.EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              child: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  GradientText(text: name),
                  const material.SizedBox(height: 17),
                  material.Column(
                    children: List.generate(optionsList.length, (i) {
                      final opt = optionsList[i] ?? {};
                      final optionName = opt['optionName'] ?? '';
                      final price = opt['price'] ?? 0;

                      final isChecked = localSelectedOptions.any(
                        (o) =>
                            o['optionName'] == optionName &&
                            o['price'] == price,
                      );

                      return material.Padding(
                        padding: const material.EdgeInsets.only(bottom: 15),
                        child: material.Row(
                          mainAxisAlignment:
                              material.MainAxisAlignment.spaceBetween,
                          children: [
                            material.Text(
                              optionName.isNotEmpty
                                  ? optionName
                                  : 'Unnamed Option',
                              style: const material.TextStyle(
                                fontSize: 12,
                                fontWeight: material.FontWeight.w500,
                                color: material.Color(0xFFD2D2D2),
                              ),
                            ),
                            material.Row(
                              children: [
                                material.Text(
                                  price == 0 ? '' : '+ ₹$price',
                                  style: const material.TextStyle(
                                    fontSize: 12,
                                    fontWeight: material.FontWeight.w500,
                                    color: material.Color(0xFF787878),
                                  ),
                                ),
                                TiffinCheckbox(
                                  preChecked: isChecked,
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
                    const material.Divider(
                      thickness: 0.5,
                      color: material.Color.fromARGB(255, 65, 65, 65),
                      indent: 10,
                      endIndent: 10,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    ),
  );
}

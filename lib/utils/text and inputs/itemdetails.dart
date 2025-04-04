import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/cart.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/veg.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ItemDetails extends StatefulWidget {
  final int price;
  final String title;
  final dynamic item;
  final List<dynamic> optionSet;
  final VoidCallback onTap;
  final int index;
  const ItemDetails({
    super.key,
    required this.price,
    required this.title,
    required this.optionSet,
    required this.item,
    required this.onTap,
    required this.index,
  });

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

List<dynamic> selectedOptions = [];

void handleCheckbox(dynamic option, bool isChecked) {
  if (isChecked) {
    selectedOptions.add(option);
  } else {
    selectedOptions.remove(option);
  }
}

class _ItemDetailsState extends State<ItemDetails> {
  late bool added = false;
  @override
  void initState() {
    added = isItemInCart();
    super.initState();
  }

  bool isItemInCart() {
    bool exists = Cart.cart.any(
      (cartItem) => cartItem['item']['itemName'] == widget.item['itemName'],
    );

    if (exists) {
      counter =
          Cart.cart.firstWhere(
            (cartItem) =>
                cartItem['item']['itemName'] == widget.item['itemName'],
          )['quantity'];
    }

    return exists;
  }

  void updateQuantity() {
    for (var cartItem in Cart.cart) {
      if (cartItem['item']['itemName'] == widget.item['itemName']) {
        cartItem['quantity'] = counter;
        break;
      }
    }
  }

  void removeFromCart() {
    for (var cartItem in Cart.cart) {
      if (cartItem['item']['itemName'] == widget.item['itemName']) {
        Cart.cart.remove(cartItem);
        break;
      }
    }
    setState(() {
      added = false;
    });
    Cart.totalPrice -= widget.price;
  }

  late int counter = 1;

  void updateItemUi() {
    setState(() {
      added = isItemInCart();
      print(widget.item['itemTagIds']);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.5),
                      color: Color(0xFFF78080),
                    ),
                    child: Center(
                      child:
                          (widget.index == 0)
                              ? Text(
                                'Best Seller',
                                style: TextStyle(
                                  fontSize: 6,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB30000),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              (added)
                  ? Container(
                    width: 54,
                    height: 26,
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
                              () => setState(() {
                                counter == 1 ? removeFromCart() : counter--;
                                updateQuantity();
                              }),
                          child: LucideIconWidget(
                            icon: LucideIcons.minus,
                            size: 11,
                          ),
                        ),
                        Text(
                          '$counter',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              counter++;
                              updateQuantity();
                            });
                          },
                          child: LucideIconWidget(
                            icon: LucideIcons.plus,
                            size: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                  : SizedBox(
                    width: 54,
                    height: 26,
                    child: ElevatedButton(
                      style: ButtonStyle(
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
                                Theme.of(context).textTheme,
                                widget.optionSet,
                                widget.item,
                                widget.onTap,
                                updateItemUi,
                              ),
                            ];
                          },
                          modalTypeBuilder: (context) => WoltModalType.dialog(),
                        );
                      },
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 9,
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
              fontSize: 10,
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
  TextTheme textTheme,
  List<dynamic> optionSet,
  dynamic item,
  VoidCallback updateUI,
  VoidCallback updateItemUi,
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
          // Handle the add to cart action here
          var itemPrice = item['price'];
          for (var options in selectedOptions) {
            itemPrice += options['price'];
          }
          var cartItem = {
            'item': item,
            'options': selectedOptions,
            'price': itemPrice,
            'quantity': 1,
          };

          Cart.cart.add(cartItem);
          Cart.totalPrice += itemPrice;
          updateUI();
          updateItemUi();
          Navigator.pop(context);
        },
      ),
    ),
    useSafeArea: true,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        spacing: 15,
        children: [
          ...optionSet.map((e) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e['name']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      backgroundColor: Color(0xFF3E3E3E),
                    ),
                  ),
                  SizedBox(height: 17),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(e['options'].length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              e['options'][index]['optionName'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFD2D2D2),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  (e['options'][index]['price'] == 0)
                                      ? ''
                                      : '+ ₹${e['options'][index]['price']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF787878),
                                  ),
                                ),
                                TiffinCheckbox(
                                  preChecked:
                                      (e['options'][index]['price'] == 0)
                                          ? true
                                          : false,
                                  onChanged: (isChecked) {
                                    handleCheckbox(
                                      e['options'][index],
                                      isChecked,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
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

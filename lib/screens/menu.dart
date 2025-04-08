import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tiffinwala/constants/cart.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/category.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/carousel.dart';
import 'package:tiffinwala/utils/coupen.dart';
import 'package:tiffinwala/utils/menucontrols.dart';
import 'package:http/http.dart' as http;
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/itemdetails.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

List<dynamic> categories = [];
List<dynamic> items = [];
List<dynamic> optionSets = [];
List<dynamic> categoryItems = [];
List<dynamic> optionSetItemWise = [];

List<dynamic> menu = [];

bool showCart = false;

TextEditingController searchController = TextEditingController();

class _MenuState extends State<Menu> {
  late Razorpay _razorpay;
  late double totalPrice = 0.0;

  void totalCartPrice() {
    totalPrice = 0.0;
    for (var item in Cart.items) {
      totalPrice += item.totalPrice;
    }
    setState(() {});
  }

  Future<void> getMenu() async {
    var response = await http.get(
      Uri.parse('${BaseUrl.url}/menu'),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = await jsonDecode(response.body);

    if (jsonRes['status']) {
      categories = jsonRes['data']['categories'];
      items = jsonRes['data']['items'];
      optionSets = jsonRes['data']['optionSets'];

      for (var item in items) {
        List<dynamic> optionSetItems = [];
        if (item['optionSetIds'] != null) {
          for (var optionSetId in item['optionSetIds']) {
            var optionSetItem = optionSets.firstWhere(
              (element) => element['optionSetId'] == optionSetId,
            );
            optionSetItems.add(optionSetItem);
          }
        }
        optionSetItemWise.add(optionSetItems.isNotEmpty ? optionSetItems : []);
      }

      for (var i = 0; i < items.length; i++) {
        var newItem = {'item': items[i], 'optionSet': optionSetItemWise[i]};
        menu.add(newItem);
      }

      for (var category in categories) {
        List itemCategory =
            menu
                .where(
                  (element) =>
                      element['item']['categoryId'] == category['categoryId'],
                )
                .toList();
        categoryItems.add(itemCategory);
      }
      categories = categories.reversed.toList();
      categoryItems = categoryItems.reversed.toList();

      setState(() {});
    } else {
      log(jsonRes['message']);
    }
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_U3VZm3qrX8l8I8',
      'amount': totalPrice * 100,
      'name': 'Test Corp',
      'description': 'Test Payment',
      'prefill': {'contact': '9123456789', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle successful payment
    print("Payment Successful: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment error
    print("Payment Error: ${response.code} | ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    print("External Wallet Selected: ${response.walletName}");
  }

  void updateUI() {
    setState(() {
      if (Cart.items.isNotEmpty) {
        showCart = true;
      } else {
        showCart = false;
      }
    });
    totalCartPrice();
  }

  @override
  void initState() {
    getMenu();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  TiffinAppBar(onTap: updateUI),
                  SliverToBoxAdapter(child: Address()),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: MenuControls(updateUI: updateUI)),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: PosterCarousel()),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: CouponCode()),
                  SliverToBoxAdapter(child: SizedBox(height: 7)),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                        controller: searchController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            List<List<dynamic>> newCategoryItems = [];

                            for (int i = 0; i < categories.length; i++) {
                              List<dynamic> filteredItems =
                                  categoryItems[i].where((element) {
                                    return element['item']['itemName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase());
                                  }).toList();

                              newCategoryItems.add(filteredItems);
                            }

                            setState(() {
                              categoryItems = newCategoryItems;
                            });
                          } else {
                            optionSetItemWise.clear();
                            menu.clear();
                            categoryItems.clear();
                            getMenu();
                          }
                        },
                        cursorOpacityAnimates: true,
                        decoration: InputDecoration(
                          hintText: 'Search for items',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondary.withAlpha(100),
                          ),
                          filled: true,
                          fillColor: AppColors.accent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(LucideIcons.search, size: 16),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 7)),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                if (index >= categoryItems.length) {
                                  return SizedBox();
                                }

                                if (categoryItems[index].length == 0) {
                                  return SizedBox();
                                }

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Category(
                                    title: categories[index]['name'],
                                    items: categoryItems[index],
                                    updateUI: updateUI,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 5)),
                ],
              ),
            ),
            Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Visibility(
                    visible: showCart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(250),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            spacing: 2,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${Cart.items.length} items in cart',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                '₹ ${totalPrice.toInt()}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          TiffinButton(
                            label: 'CART',
                            width: 50,
                            height: 24,
                            onPressed: () {
                              totalCartPrice();
                              WoltModalSheet.show(
                                context: context,
                                pageListBuilder: (context) {
                                  return [
                                    cart(context, _openCheckout, totalPrice),
                                  ];
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .animate(key: ValueKey(showCart))
                .slideY(
                  begin: 1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
          ],
        ),
      ),
    );
  }
}

SliverWoltModalSheetPage cart(
  BuildContext context,
  VoidCallback openCheckout,
  double totalPrice,
) {
  return WoltModalSheetPage(
    pageTitle: Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Row(
        children: [
          Text(
            'View your',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 5),
          GradientText(text: 'Cart'),
        ],
      ),
    ),
    stickyActionBar: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${Cart.items.length} items in cart',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '₹ ${totalPrice.toInt()}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          TiffinButton(
            label: 'PAY NOW',
            width: 70,
            height: 27,
            onPressed: openCheckout,
          ),
        ],
      ),
    ),
    forceMaxHeight: false,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          Column(
            children: List.generate(Cart.items.length, (index) {
              return ItemDetails(
                isCartItem: true,
                price: Cart.items[index].totalPrice.toInt(),
                title: Cart.items[index].item['itemName'],
                optionSet: Cart.items[index].options,
                item: Cart.items[index].item,
                onTap: () {},
                index: index,
              );
            }),
          ),
          SizedBox(height: 50),
        ],
      ),
    ),
  );
}

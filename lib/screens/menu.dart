import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart' as material;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/category.dart';
import 'package:tiffinwala/utils/modal%20pages/cart.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/carousel.dart';
import 'package:tiffinwala/utils/coupen.dart';
import 'package:tiffinwala/utils/menucontrols.dart';
import 'package:http/http.dart' as http;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Menu extends ConsumerStatefulWidget {
  const Menu({super.key});

  @override
  ConsumerState<Menu> createState() => _MenuState();
}

List<dynamic> categories = [];
List<dynamic> items = [];
List<dynamic> optionSets = [];
List<dynamic> categoryItems = [];
List<dynamic> optionSetItemWise = [];

List<dynamic> menu = [];

List<GlobalKey> categoryKeys = [];

TextEditingController searchController = TextEditingController();

class _MenuState extends ConsumerState<Menu> {
  late Razorpay _razorpay;
  final ItemScrollController _scrollController = ItemScrollController();

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

      categoryKeys = List.generate(categories.length, (index) => GlobalKey());

      setState(() {});
    } else {
      log(jsonRes['message']);
    }
  }

  void _openCheckout(double price) {
    var options = {
      'key': 'rzp_test_U3VZm3qrX8l8I8',
      'amount': price * 100,
      'name': 'Tiffinwala',
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("Payment Successful: ${response.paymentId}");

    List<dynamic> orders = [];
    List<CartItems> cartItems = ref.watch(cartProvider);
    for (var item in cartItems) {
      var order = {
        'itemName': item.item['itemName'],
        'price': item.totalPrice,
        'quantity': item.quantity,
      };

      orders.add(order);
    }

    double totalPrice = ref.read(cartProvider.notifier).getTotalPrice();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone')!;

    var body = {'order': orders, 'price': totalPrice, 'phone': phone};
    var res = await http.post(
      Uri.parse('${BaseUrl.url}/order/new'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = jsonDecode(res.body);

    if (jsonRes['status']) {
      ref.read(cartProvider.notifier).clearCart();
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        getMenu();
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment error
    log("Payment Error: ${response.code} | ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    log("External Wallet Selected: ${response.walletName}");
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
  void dispose() {
    _razorpay.clear();
    searchController.dispose();
    super.dispose();
  }

void _scrollToCategory(int index) {
  Navigator.of(context).pop();
  _scrollController.scrollTo(
    index: index,
    duration: Duration(milliseconds: 600),
    curve: Curves.easeInOut,
  );
}


  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    List<CartItems> cartItems = ref.watch(cartProvider);
    double price = ref.watch(
      cartProvider.notifier.select((cart) => cart.getTotalPrice()),
    );
    return material.Scaffold(
      body: RefreshTrigger(
        key: _refreshTriggerKey,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          getMenu();
        },
        child: SafeArea(
          child: DrawerOverlay(
            child: Stack(
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      TiffinAppBar(centerTitle: false, title: 'Tiffinwala'),
                      SliverToBoxAdapter(
                        child: material.Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Address(),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: MenuControls()),
                      SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: PosterCarousel()),
                      SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: CouponCode()),
                      SliverToBoxAdapter(child: SizedBox(height: 7)),
                      SliverToBoxAdapter(
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: material.Row(
                            spacing: 4,
                            children: [
                              Expanded(
                                child: material.TextField(
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                  controller: searchController,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      List<List<dynamic>> newCategoryItems = [];

                                      for (
                                        int i = 0;
                                        i < categories.length;
                                        i++
                                      ) {
                                        List<dynamic> filteredItems =
                                            categoryItems[i].where((element) {
                                              return element['item']['itemName']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(
                                                    value.toLowerCase(),
                                                  );
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
                                  decoration: material.InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 9),
                                    hintText: 'Search for items',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.secondary.withAlpha(100),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.accent,
                                    border: material.OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(
                                      lucide.LucideIcons.search,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  WoltModalSheet.show(
                                    context: context,
                                    modalTypeBuilder:
                                        (context) => WoltModalType.dialog(),
                                    pageListBuilder: (context) {
                                      return [
                                        menuPopUp(
                                          context,
                                          categories,
                                          _scrollToCategory,
                                        ),
                                      ];
                                    },
                                  );
                                },
                                child: Container(
                                  width: 80,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    spacing: 5,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Menu',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.secondary.withAlpha(
                                            200,
                                          ),
                                        ),
                                      ),
                                      lucide.LucideIconWidget(
                                        icon: lucide.LucideIcons.utensils,
                                        size: 13,
                                        color: AppColors.secondary.withAlpha(
                                          200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                                child: ScrollablePositionedList.builder(
                                  itemScrollController: _scrollController,
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
                                      child: material.Container(
                                        key: categoryKeys[index],
                                        child: Category(
                                          title: categories[index]['name'],
                                          items: categoryItems[index],
                                        ),
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
                        visible: cartItems.isNotEmpty,
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
                                    '${cartItems.length} items in cart',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  Text(
                                    '₹ $price',
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
                                  WoltModalSheet.show(
                                    context: context,
                                    pageListBuilder: (context) {
                                      return [
                                        cart(
                                          context,
                                          () => _openCheckout(price),
                                        ),
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
                    .animate(key: ValueKey(cartItems.isNotEmpty))
                    .slideY(
                      begin: 1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

WoltModalSheetPage menuPopUp(
  BuildContext context,
  List<dynamic> categories,
  Function(int) scrollToCategory,
) {
  return WoltModalSheetPage(
    hasTopBarLayer: true,
    topBar: const Center(
      child: Text(
        'Menu',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    scrollController: ScrollController(),
    isTopBarLayerAlwaysVisible: true,
    useSafeArea: true,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: List.generate(categories.length, (index) {
          return GestureDetector(
            onTap: () {
              scrollToCategory(index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              margin: EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const material.Color.fromARGB(255, 37, 37, 37),
              ),
              child: Text(
                categories[index]['name'],
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

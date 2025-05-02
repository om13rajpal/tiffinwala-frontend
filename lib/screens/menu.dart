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
import 'package:tiffinwala/providers/address.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/loyalty.dart';
import 'package:tiffinwala/providers/ordermode.dart';
import 'package:tiffinwala/providers/points.dart';
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
  List<List<dynamic>> allCategoryItems = [];
List<dynamic> categoryItems = [];
List<dynamic> optionSetItemWise = [];

List<dynamic> menu = [];

List<GlobalKey> categoryKeys = [];
int loyaltyPoints = 0;

TextEditingController searchController = TextEditingController();

class _MenuState extends ConsumerState<Menu> {
  late Razorpay _razorpay;
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollController _outerController = ScrollController();
  late String address = '';

  Future<void> getLoyaltyPoints(WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phone = prefs.getString('phone');
    var token = prefs.getString('token');

    var response = await http.get(
      Uri.parse('${BaseUrl.url}/user/loyalty/$phone'),
      headers: {
        'Content-Type': "application/json",
        "authorization": "Bearer $token",
      },
    );

    var jsonRes = jsonDecode(response.body);
    if (jsonRes['status']) {
      loyaltyPoints = jsonRes['data'];
      ref.read(setPointsProvider.notifier).setPoints(loyaltyPoints);
    }
  }

  Future<void> getMenu() async {
  // Clear any existing data so we start fresh
  categories.clear();
  items.clear();
  optionSets.clear();
  optionSetItemWise.clear();
  menu.clear();
  categoryItems.clear();
  allCategoryItems.clear(); // <-- master backup

  final response = await http.get(
    Uri.parse('${BaseUrl.url}/menu'),
    headers: {'Content-Type': 'application/json'},
  );
  final jsonRes = jsonDecode(response.body);

  if (jsonRes['status']) {
    // 1. Load raw data
    categories = jsonRes['data']['categories'];
    items = jsonRes['data']['items'];
    optionSets = jsonRes['data']['optionSets'];

    // 2. Build optionSetItemWise list
    for (var item in items) {
      final List<dynamic> opts = [];
      if (item['optionSetIds'] != null) {
        for (var id in item['optionSetIds']) {
          opts.add(optionSets.firstWhere((o) => o['optionSetId'] == id));
        }
      }
      optionSetItemWise.add(opts);
    }

    // 3. Build menu entries
    for (var i = 0; i < items.length; i++) {
      menu.add({
        'item': items[i],
        'optionSet': optionSetItemWise[i],
      });
    }

    // 4. Group into categories
    for (var cat in categories) {
      final List<dynamic> inThisCat = menu.where((entry) {
        return entry['item']['categoryId'] == cat['categoryId'];
      }).toList();
      categoryItems.add(inThisCat);
    }

    // 5. Reverse if you want the last category first
    categories = categories.reversed.toList();
    categoryItems = categoryItems.reversed.toList();

    // 6. KEEP A MASTER COPY FOR SEARCH RESTORATION
    allCategoryItems = categoryItems
        .map((list) => List<dynamic>.from(list))
        .toList();

    // 7. Generate your scroll or list keys
    categoryKeys = List.generate(categories.length, (_) => GlobalKey());

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

    bool usingLoyaltyPoints = ref.watch(isUsingLoyaltyProvider);

    if (usingLoyaltyPoints) {
      var body = {'phone': phone, 'points': -loyaltyPoints};

      var res = await http.post(
        Uri.parse('${BaseUrl.url}/user/loyalty'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      var jsonRes = jsonDecode(res.body);

      if (jsonRes['status']) {
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Loyalty points used successfully');
      } else {
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Failed to use loyalty points: ${jsonRes['message']}');
      }
    }

    String orderMode = ref.watch(setOrderModeProvider);
    var body = {
      'order': orders,
      'price': totalPrice,
      'phone': phone,
      'paymentStatus': 'completed',
      'paymentMethod': 'razorpay',
      'orderMode': orderMode.toLowerCase(),
    };
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

  void _handlePayOnDelivery() async {
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

    bool usingLoyaltyPoints = ref.watch(isUsingLoyaltyProvider);

    if (usingLoyaltyPoints) {
      var body = {'phone': phone, 'points': -loyaltyPoints};

      var res = await http.post(
        Uri.parse('${BaseUrl.url}/user/loyalty'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      var jsonRes = jsonDecode(res.body);

      if (jsonRes['status']) {
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Loyalty points used successfully');
      } else {
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Failed to use loyalty points: ${jsonRes['message']}');
      }
    }
    String orderMode = ref.watch(setOrderModeProvider);

    var body = {
      'order': orders,
      'price': totalPrice,
      'phone': phone,
      'paymentStatus': 'pending',
      'paymentMethod': 'cod',
      'orderMode': orderMode.toLowerCase(),
    };
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

  Future<void> getUserData(WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phone = prefs.getString('phone');
    var token = prefs.getString('token');

    var res = await http.get(
      Uri.parse('${BaseUrl.url}/user/$phone'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    var jsonRes = jsonDecode(res.body);
    if (jsonRes['status']) {
      address = jsonRes['data']['address'];
      ref.read(setAddressProvider.notifier).setAddress(address);
    } else {
      print('Failed to fetch user data: ${jsonRes['message']}');
    }
  }

  void _onSearchChanged(String value) {
    final query = value.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        categoryItems = allCategoryItems.map((itemsList) {
          return itemsList
              .where((element) =>
                  element['item']['itemName']
                      .toString()
                      .toLowerCase()
                      .contains(query))
              .toList();
        }).toList();
      } else {
        // restore original
        categoryItems = allCategoryItems
            .map((list) => List<dynamic>.from(list))
            .toList();
      }
    });
  }

  @override
  void initState() {
    getMenu();
    getUserData(ref);
    getLoyaltyPoints(ref);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = categoryKeys[index].currentContext;
      if (keyContext == null) return;

      final box = keyContext.findRenderObject() as RenderBox;
      final yPos = box.localToGlobal(Offset.zero).dy;
      final targetOffset =
          _outerController.offset + yPos - material.kToolbarHeight;

      _outerController.animateTo(
        targetOffset.clamp(0.0, _outerController.position.maxScrollExtent),
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CartItems> cartItems = ref.watch(cartProvider);
    address = ref.watch(setAddressProvider);
    loyaltyPoints = ref.watch(setPointsProvider);
    double price = ref.watch(
      cartProvider.notifier.select((cart) => cart.getTotalPrice()),
    );
    return material.Scaffold(
      body: SafeArea(
        child: DrawerOverlay(
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: CustomScrollView(
                  controller: _outerController,
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    TiffinAppBar(centerTitle: false, title: 'Tiffinwala'),
                    SliverToBoxAdapter(
                      child: material.Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Address(address: address),
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
                                onChanged: _onSearchChanged,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      color: AppColors.secondary.withAlpha(200),
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
                        // height: MediaQuery.of(context).size.height * 0.7,
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
                                        () => _handlePayOnDelivery(),
                                        loyaltyPoints,
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

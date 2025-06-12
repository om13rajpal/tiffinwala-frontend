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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/address.dart';
import 'package:tiffinwala/providers/addressloaded.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/ismenuloaded.dart';
import 'package:tiffinwala/providers/loyalty.dart';
import 'package:tiffinwala/providers/ordermode.dart';
import 'package:tiffinwala/providers/points.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/category.dart';
import 'package:tiffinwala/utils/modal%20pages/cart.dart';
import 'package:tiffinwala/utils/modal%20pages/popup.dart';
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

// list declarations
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
  late String token;
  late String phone;
  late Razorpay _razorpay;
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollController _outerController = ScrollController();
  late String address = '';
  late bool isLoading = ref.watch(isMenuLoadedProvider);
  late bool isAddressLoading = ref.watch(isAddressLoadedProvider);

  // initializing shared preferences
  Future<void> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(isMenuLoadedProvider.notifier).setMenu(true);
    ref.read(isAddressLoadedProvider.notifier).setAddressLoaded(true);
    phone = prefs.getString('phone')!;
    token = prefs.getString('token')!;

    if (token.isNotEmpty && phone.isNotEmpty) {
      await getMenu();
      await getUserData(ref);
      await getLoyaltyPoints(ref);
    }
  }

  // fetching loyalty points
  Future<void> getLoyaltyPoints(WidgetRef ref) async {
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

  // fetching menu from the server
  Future<void> getMenu() async {
    categories.clear();
    items.clear();
    optionSets.clear();
    optionSetItemWise.clear();
    menu.clear();
    categoryItems.clear();
    allCategoryItems.clear();

    final response = await http.get(
      Uri.parse('${BaseUrl.url}/menu'),
      headers: {'Content-Type': 'application/json'},
    );
    final jsonRes = jsonDecode(response.body);

    if (jsonRes['status']) {
      categories = jsonRes['data']['categories'];
      items = jsonRes['data']['items'];
      optionSets = jsonRes['data']['optionSets'];

      for (var item in items) {
        final List<dynamic> opts = [];
        if (item['optionSetIds'] != null) {
          for (var id in item['optionSetIds']) {
            opts.add(optionSets.firstWhere((o) => o['optionSetId'] == id));
          }
        }
        optionSetItemWise.add(opts);
      }

      for (var i = 0; i < items.length; i++) {
        menu.add({'item': items[i], 'optionSet': optionSetItemWise[i]});
      }

      for (var cat in categories) {
        final List<dynamic> inThisCat =
            menu.where((entry) {
              return entry['item']['categoryId'] == cat['categoryId'];
            }).toList();
        categoryItems.add(inThisCat);
      }

      categories = categories.reversed.toList();
      categoryItems = categoryItems.reversed.toList();

      allCategoryItems =
          categoryItems.map((list) => List<dynamic>.from(list)).toList();

      categoryKeys = List.generate(categories.length, (_) => GlobalKey());
      ref.read(isMenuLoadedProvider.notifier).setMenu(false);
      setState(() {});
    } else {
      log(jsonRes['message']);
    }
  }

  // opening razorpay checkout page for payment
  void _openCheckout(double price) {
    var options = {
      'key': 'rzp_test_U3VZm3qrX8l8I8',
      'amount': price * 100,
      'name': 'Tiffinwala',
      'description': 'Order Payment',
      'prefill': {'contact': phone},
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

  // handling razorpay payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    List<dynamic> orders = [];
    List<CartItems> cartItems = ref.watch(cartProvider);
    for (var item in cartItems) {
      var order = {
        'shortName': item.item['itemName'],
        'skuCode': item.item['itemName'],
        'unitPrice': item.totalPrice,
        'quantity': item.quantity,
      };

      orders.add(order);
    }

    double totalPrice = ref.read(cartProvider.notifier).getTotalPrice();

    bool usingLoyaltyPoints = ref.watch(isUsingLoyaltyProvider);
    final int discount =
        usingLoyaltyPoints
            ? (loyaltyPoints > totalPrice ? totalPrice.toInt() : loyaltyPoints)
            : 0;

    var body = {'phone': phone, 'points': -discount};

    String orderMode = ref.watch(setOrderModeProvider);

    var orderbody = {
      'order': orders,
      'price': totalPrice,
      'phone': phone,
      'paymentStatus': 'completed',
      'paymentMethod': 'razorpay',
      'orderMode': orderMode.toLowerCase(),
      'discount': discount,
    };

    var res = await http.post(
      Uri.parse('${BaseUrl.url}/user/loyalty'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = jsonDecode(res.body);

    if (jsonRes['status']) {
      var res = await http.post(
        Uri.parse('${BaseUrl.url}/order/new'),
        body: jsonEncode(orderbody),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      var jsonRes = jsonDecode(res.body);

      if (jsonRes['status']) {
        ref.read(cartProvider.notifier).clearCart();
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Loyalty points used successfully');
      }
    } else {
      ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
      log('Failed to use loyalty points: ${jsonRes['message']}');
    }
  }

  // handling pay on delivery
  void _handlePayOnDelivery() async {
    List<dynamic> orders = [];
    List<CartItems> cartItems = ref.watch(cartProvider);
    for (var item in cartItems) {
      var order = {
        'shortName': item.item['itemName'],
        'skuCode': item.item['itemName'],
        'unitPrice': item.totalPrice,
        'quantity': item.quantity,
      };

      orders.add(order);
    }

    double totalPrice = ref.read(cartProvider.notifier).getTotalPrice();

    bool usingLoyaltyPoints = ref.watch(isUsingLoyaltyProvider);
    final int discount =
        usingLoyaltyPoints
            ? (loyaltyPoints > totalPrice ? totalPrice.toInt() : loyaltyPoints)
            : 0;

    var body = {'phone': phone, 'points': -discount};

    String orderMode = ref.watch(setOrderModeProvider);

    var orderbody = {
      'order': orders,
      'price': totalPrice,
      'phone': phone,
      'paymentStatus': 'pending',
      'paymentMethod': 'cod',
      'orderMode': orderMode.toLowerCase(),
      'discount': discount,
    };

    var res = await http.post(
      Uri.parse('${BaseUrl.url}/user/loyalty'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = jsonDecode(res.body);

    if (jsonRes['status']) {
      var res = await http.post(
        Uri.parse('${BaseUrl.url}/order/new'),
        body: jsonEncode(orderbody),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      var jsonRes = jsonDecode(res.body);

      if (jsonRes['status']) {
        ref.read(cartProvider.notifier).clearCart();
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Loyalty points used successfully');
      }
    } else {
      ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
      log('Failed to use loyalty points: ${jsonRes['message']}');
    }
  }

  // handling razorpay payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    log("Payment Error: ${response.code} | ${response.message}");
  }

  // handling external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    log("External Wallet Selected: ${response.walletName}");
  }

  // fetching user data from the server
  Future<void> getUserData(WidgetRef ref) async {
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
      ref.read(isAddressLoadedProvider.notifier).setAddressLoaded(false);
    } else {
      log('Failed to fetch user data: ${jsonRes['message']}');
    }
  }

  // handling search input changes
  void _onSearchChanged(String value) {
    final query = value.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        categoryItems =
            allCategoryItems.map((itemsList) {
              return itemsList
                  .where(
                    (element) => element['item']['itemName']
                        .toString()
                        .toLowerCase()
                        .contains(query),
                  )
                  .toList();
            }).toList();
      } else {
        // restore original
        categoryItems =
            allCategoryItems.map((list) => List<dynamic>.from(list)).toList();
      }
    });
  }

  @override
  void initState() {
    initData();

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

  // scrolling to the selected category
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
    // provider declarations
    List<CartItems> cartItems = ref.watch(cartProvider);
    address = ref.watch(setAddressProvider);
    loyaltyPoints = ref.watch(setPointsProvider);
    isLoading = ref.watch(isMenuLoadedProvider);
    isAddressLoading = ref.watch(isAddressLoadedProvider);
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
                        child:
                            (isAddressLoading)
                                ? Row(
                                  children: [
                                    lucide.LucideIconWidget(
                                      icon: LucideIcons.map,
                                      strokeWidth: 2,
                                      color: AppColors.icon,
                                      size: 14,
                                    ),
                                    SizedBox(width: 10),
                                    Skeletonizer(
                                      containersColor: AppColors.accent,
                                      enableSwitchAnimation: true,
                                      effect: PulseEffect(
                                        from: const material.Color.fromARGB(
                                          255,
                                          126,
                                          126,
                                          126,
                                        ),
                                        to: const material.Color.fromARGB(
                                          255,
                                          82,
                                          82,
                                          82,
                                        ).withAlpha(100),
                                        duration: Duration(milliseconds: 800),
                                      ),
                                      enabled: isLoading,
                                      child: material.Text(
                                        'house no. 381 sector 16 -17 hisar 120551',
                                        style: TextStyle(
                                          fontSize: 11,
                                          overflow: TextOverflow.ellipsis,
                                          color: AppColors.icon,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Address(address: address),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: MenuControls()),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: PosterCarousel()),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: CouponCode()),
                    SliverToBoxAdapter(child: SizedBox(height: 7)),
                    SliverToBoxAdapter(child: searchBar(context)),
                    SliverToBoxAdapter(child: SizedBox(height: 7)),
                    SliverToBoxAdapter(child: tiffinMenu(context)),
                    SliverToBoxAdapter(child: SizedBox(height: 5)),
                  ],
                ),
              ),
              viewCart(cartItems, price, context)
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

  // Positioned view cart button
  material.Positioned viewCart(
    List<CartItems> cartItems,
    double price,
    material.BuildContext context,
  ) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Visibility(
        visible: cartItems.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 60,
          decoration: BoxDecoration(
            color: const material.Color.fromARGB(
              255,
              22,
              22,
              22,
            ).withAlpha(250),
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
                width: 55,
                height: 28,
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
    );
  }

  // Tiffin menu container
  material.Container tiffinMenu(material.BuildContext context) {
    return Container(
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
          child:
              (isLoading)
                  ? Skeletonizer(
                    containersColor: AppColors.accent,
                    enableSwitchAnimation: true,
                    effect: PulseEffect(
                      from: const material.Color.fromARGB(255, 126, 126, 126),
                      to: const material.Color.fromARGB(
                        255,
                        82,
                        82,
                        82,
                      ).withAlpha(100),
                      duration: Duration(milliseconds: 800),
                    ),
                    enabled: isLoading,
                    child: material.Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Column(
                        children: List.generate(7, (index) {
                          return material.Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: material.Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Spring roll combination'),
                                    Text('879 ka hai ye'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  )
                  : ScrollConfiguration(
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
                        String categoryName =
                            categories[index]['name'].toString().toLowerCase();
                        if (!categoryName.contains('tiffin')) {
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
    );
  }

  // Search bar container
  material.Container searchBar(material.BuildContext context) {
    return Container(
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
                prefixIcon: Icon(lucide.LucideIcons.search, size: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              WoltModalSheet.show(
                context: context,
                modalTypeBuilder: (context) => WoltModalType.dialog(),
                pageListBuilder: (context) {
                  return [
                    menuPopUp(
                      context,
                      categories,
                      categoryItems,
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
                      color: AppColors.secondary.withAlpha(200),
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
    );
  }
}

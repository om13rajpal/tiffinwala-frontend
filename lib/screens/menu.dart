import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart' as material;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
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
import 'package:tiffinwala/providers/charge.dart';
import 'package:tiffinwala/providers/coupon.dart';
import 'package:tiffinwala/providers/discount.dart';
import 'package:tiffinwala/providers/ismenuloaded.dart';
import 'package:tiffinwala/providers/loyalty.dart';
import 'package:tiffinwala/providers/ordermode.dart';
import 'package:tiffinwala/providers/points.dart';
import 'package:tiffinwala/providers/status.dart';
import 'package:tiffinwala/screens/success.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/category.dart';
import 'package:tiffinwala/utils/coupon.dart';
import 'package:tiffinwala/utils/modal%20pages/cart.dart';
import 'package:tiffinwala/utils/modal%20pages/popup.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/carousel.dart';
import 'package:tiffinwala/utils/coupen.dart';
import 'package:tiffinwala/utils/menucontrols.dart';
import 'package:http/http.dart' as http;
import 'package:tiffinwala/utils/text%20and%20inputs/toast.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Menu extends ConsumerStatefulWidget {
  const Menu({super.key});

  @override
  ConsumerState<Menu> createState() => _MenuState();
}

Future<Map<String, dynamic>> apiGet(
  String path, {
  Map<String, String>? headers,
}) async {
  final res = await http.get(
    Uri.parse('${BaseUrl.url}$path'),
    headers: {'Content-Type': 'application/json', ...?headers},
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> apiPost(
  String path,
  dynamic body, {
  Map<String, String>? headers,
}) async {
  final res = await http.post(
    Uri.parse('${BaseUrl.url}$path'),
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json', ...?headers},
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}

List<Map<String, dynamic>> buildOrders(List<CartItems> cartItems) {
  return cartItems
      .map(
        (item) => {
          'shortName': item.item['itemName'],
          'skuCode': item.item['itemName'],
          'unitPrice': item.totalPrice,
          'quantity': item.quantity,
          'options':
              item.options.map((opt) {
                return {'name': opt['optionName'], 'price': opt['price']};
              }).toList(),
        },
      )
      .toList();
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
  late bool isLoading = ref.watch(isMenuLoadedProvider);

  // initializing shared preferences
  Future<void> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(isMenuLoadedProvider.notifier).setMenu(true);
    phone = prefs.getString('phone')!;
    token = prefs.getString('token')!;

    if (token.isNotEmpty && phone.isNotEmpty) {
      await getMenu();
      await getUserData(ref, phone, token);
      await getLoyaltyPoints(ref);
    }
  }

  // fetching loyalty points
  Future<void> getLoyaltyPoints(WidgetRef ref) async {
    final jsonRes = await apiGet(
      '/user/loyalty/$phone',
      headers: {'authorization': 'Bearer $token'},
    );

    if (jsonRes['status'] == true) {
      loyaltyPoints = jsonRes['data'] ?? 0;
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

    final jsonRes = await apiGet('/menu');

    if (jsonRes['status'] != true) {
      log(jsonRes['message'] ?? 'Unknown error loading menu.');
      return;
    }

    categories = jsonRes['data']['categories'];
    items = jsonRes['data']['items'];
    optionSets = jsonRes['data']['optionSets'];
    final chargesList = jsonRes['data']['charges'] as List;

    final optionSetMap = {for (var opt in optionSets) opt['optionSetId']: opt};

    optionSetItemWise =
        items.map((item) {
          final ids = item['optionSetIds'] as List?;
          return ids?.map((id) => optionSetMap[id]).toList() ?? [];
        }).toList();

    menu = [
      for (var i = 0; i < items.length; i++)
        {'item': items[i], 'optionSet': optionSetItemWise[i]},
    ];

    for (var cat in categories) {
      final itemsInCategory =
          menu
              .where(
                (entry) => entry['item']['categoryId'] == cat['categoryId'],
              )
              .toList();

      categoryItems.add(itemsInCategory);
    }

    double packaging = 0.0;
    double delivery = 0.0;
    for (final chargeJson in chargesList) {
      switch (chargeJson['name']) {
        case "App Packaging Charges":
          packaging = (chargeJson['chargeRate'] as num).toDouble();
          break;
        case "App Delivery Charges":
          delivery = (chargeJson['chargeRate'] as num).toDouble();
          break;
      }
    }

    ref.read(chargesProvider.notifier).state = {
      'packagingCharge': packaging,
      'deliveryCharge': delivery,
    };

    categories = categories.reversed.toList();
    categoryItems = categoryItems.reversed.toList();

    allCategoryItems =
        categoryItems.map((list) => List<dynamic>.from(list)).toList();

    categoryKeys = List.generate(categories.length, (_) => GlobalKey());

    ref.read(isMenuLoadedProvider.notifier).setMenu(false);
    setState(() {});
  }

  // opening razorpay checkout page for payment
  void _openCheckout(double price, String method) {
    final paymentMethodMap = {
      'netbanking': false,
      'card': false,
      'wallet': false,
      'emi': false,
      'upi': false,
      'paylater': false,
    };

    // Enable the selected method
    switch (method) {
      case 'Net Banking':
        paymentMethodMap['netbanking'] = true;
        break;
      case 'Credit Card':
      case 'Debit Card':
        paymentMethodMap['card'] = true;
        break;
      case 'Wallet':
        paymentMethodMap['wallet'] = true;
        break;
      case 'UPI':
        paymentMethodMap['upi'] = true;
        break;
    }

    var options = {
      'key': 'rzp_test_U3VZm3qrX8l8I8',
      'amount': price * 100,
      'name': 'Tiffinwala',
      'description': 'Order Payment',
      'method': paymentMethodMap,
      'prefill': {'contact': phone},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // handling razorpay payment success
Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
  final cartItems = ref.watch(cartProvider);
  final discountState = ref.read(discountProvider);
  final loyaltyDiscount = discountState.loyaltyDiscount;
  final couponDiscount = discountState.couponDiscount;

  // ✅ NEW: Calculate delivery & packaging
  final charges = ref.read(chargesProvider);
  final packagingRate = charges['packagingCharge'] ?? 0.0;
  final deliveryRate = charges['deliveryCharge'] ?? 0.0;

  final totalQuantity = ref.read(cartProvider.notifier).getTotalQuantity();

  final totalPackagingCharge = packagingRate * totalQuantity;
  final totalDeliveryCharge = deliveryRate + totalPackagingCharge;

  double totalPrice = ref
      .read(cartProvider.notifier)
      .getPayableAmount(
        ref,
        couponPercent: couponDiscount,
        loyaltyPoints: loyaltyDiscount,
      );

  final orders = buildOrders(cartItems);

  bool usingLoyaltyPoints = ref.watch(isUsingLoyaltyProvider);
  final discountPoints =
      usingLoyaltyPoints ? loyaltyPoints.clamp(0, totalPrice.toInt()) : 0;

  final body = {'phone': phone, 'points': -discountPoints};

  String orderMode = ref.watch(setOrderModeProvider);
  final couponCode = ref.read(couponProvider).code;

  final orderBody = {
    'order': orders,
    'price': totalPrice,
    'delivery': totalDeliveryCharge,
    'discount': couponDiscount,
    'loyalty': loyaltyDiscount,
    'couponCode': couponCode.isNotEmpty ? couponCode : null,
    'phone': phone,
    'paymentStatus': 'completed',
    'paymentMethod': 'razorpay',
    'orderMode': orderMode.toLowerCase(),
  };

  debugPrint('=== ORDER PAYLOAD (Razorpay) ===');
  debugPrint(jsonEncode(orderBody));

  final loyaltyRes = await apiPost('/user/loyalty', body);
  if (loyaltyRes['status']) {
    final orderRes = await apiPost(
      '/order/new',
      orderBody,
      headers: {'authorization': 'Bearer $token'},
    );

    if (orderRes['status']) {
      ref.read(cartProvider.notifier).clearCart();
      if (!mounted) return;
      ref.read(couponProvider.notifier).reset();
      ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
      log('Loyalty points used successfully');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          material.MaterialPageRoute(
            builder: (_) => Success(
              title: "Order Successful",
              message: "Your order has been received.",
              details: {"Order ID": orderRes['data']['_id']},
            ),
          ),
        );
      });
    }
  } else {
    ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
    log('Failed to use loyalty points: ${loyaltyRes['message']}');
  }
}


  // handling pay on delivery
  Future<void> _handlePayOnDelivery() async {
    final cartItems = ref.watch(cartProvider);
    final orders = buildOrders(cartItems);

    final discountState = ref.read(discountProvider);
    double loyaltyDiscount = discountState.loyaltyDiscount;
    double couponDiscount = discountState.couponDiscount;

    final subtotal = ref.read(
      cartProvider.notifier.select((cart) => cart.getNormalTotalPrice()),
    );

    if (loyaltyDiscount > subtotal) {
      loyaltyDiscount = subtotal;
    }

    bool usingLoyaltyPoints = ref.watch(isUsingLoyaltyProvider);
    final discountPoints =
        usingLoyaltyPoints ? loyaltyPoints.clamp(0, subtotal.toInt()) : 0;

    final body = {'phone': phone, 'points': -discountPoints};

    String orderMode = ref.watch(setOrderModeProvider);
    final couponCode = ref.read(couponProvider).code;

    // ✅ NEW: Calculate delivery & packaging
    final charges = ref.read(chargesProvider);
    final packagingRate = charges['packagingCharge'] ?? 0.0;
    final deliveryRate = charges['deliveryCharge'] ?? 0.0;

    final totalQuantity = ref.read(cartProvider.notifier).getTotalQuantity();

    final totalPackagingCharge = packagingRate * totalQuantity;
    final totalDeliveryCharge = deliveryRate + totalPackagingCharge;

    final orderBody = {
      'order': orders,
      'price': subtotal,
      'delivery': totalDeliveryCharge,
      'discount': couponDiscount,
      'loyalty': loyaltyDiscount,
      'couponCode': couponCode.isNotEmpty ? couponCode : null,
      'phone': phone,
      'paymentStatus': 'pending',
      'paymentMethod': 'cod',
      'orderMode': orderMode.toLowerCase(),
    };

    debugPrint('=== ORDER PAYLOAD ===');
    debugPrint(jsonEncode(orderBody));

    final loyaltyRes = await apiPost('/user/loyalty', body);
    if (loyaltyRes['status']) {
      final orderRes = await apiPost(
        '/order/new',
        orderBody,
        headers: {'authorization': 'Bearer $token'},
      );

      if (orderRes['status']) {
        ref.read(cartProvider.notifier).clearCart();
        if (!mounted) return;
        ref.read(couponProvider.notifier).reset();
        ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
        log('Loyalty points used successfully');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            material.MaterialPageRoute(
              builder:
                  (_) => Success(
                    title: "Order Successful",
                    message: "Your order has been received.",
                    details: {"Order ID": orderRes['data']['_id']},
                  ),
            ),
          );
        });
      }
    } else {
      ref.read(isUsingLoyaltyProvider.notifier).setLoading(false);
      log('Failed to use loyalty points: ${loyaltyRes['message']}');
    }
  }

  // handling razorpay payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    showToast(
      context: context,
      builder:
          (context, overlay) =>
              buildToast(context, overlay, 'Payment error, please try again!'),
      location: ToastLocation.topCenter,
    );
    log("Payment Error: ${response.code} | ${response.message}");
  }

  // handling external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    log("External Wallet Selected: ${response.walletName}");
  }

  Future<void> getUserData(WidgetRef ref, String phone, String token) async {
    final jsonRes = await apiGet(
      '/user/$phone',
      headers: {'authorization': 'Bearer $token'},
    );

    if (jsonRes['status'] == true) {
      final addresses =
          (jsonRes['data']['address'] as List<dynamic>)
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .toList();

      ref.read(addressProvider.notifier).setAddresses(addresses);
      ref.read(isAddressLoadedProvider.notifier).setAddressLoaded(true);
    } else {
      debugPrint("Failed to fetch user data: ${jsonRes['message']}");
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

  Future<void> checkStoreStatus() async {
    try {
      final response = await http.get(Uri.parse("${BaseUrl.url}/store/status"));
      final jsonRes = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        ref.read(statusProvider.notifier).state = jsonRes['store'];
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    initData();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    checkStoreStatus();
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
    final isAddressLoading = !ref.watch(isAddressLoadedProvider);
    final addresses = ref.watch(addressProvider);
    final primaryAddress = addresses.firstWhere(
      (a) => a.isPrimary,
      orElse: () => AddressModel(id: '', address: ''),
    );

    loyaltyPoints = ref.watch(setPointsProvider);
    isLoading = ref.watch(isMenuLoadedProvider);
    final discountState = ref.watch(discountProvider);

    final cartNotifier = ref.read(cartProvider.notifier);

    final double price = cartNotifier.getPayableAmount(
      ref,
      couponPercent: discountState.couponDiscount,
      loyaltyPoints: discountState.loyaltyDiscount,
    );

    bool open = ref.watch(statusProvider);

    return material.Scaffold(
      body: SafeArea(
        child: DrawerOverlay(
          child: Stack(
            children: [
              material.RefreshIndicator(
                onRefresh: () async {
                  await getMenu();
                  await getUserData(ref, phone, token);
                  await getLoyaltyPoints(ref);
                },
                child: ScrollConfiguration(
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
                                          'house no. xyz sector xy - ab abcde 1234567',
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
                                  : Address(address: primaryAddress.address),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: MenuControls()),
                      SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: PosterCarousel()),
                      SliverToBoxAdapter(child: CouponCode()),
                      SliverToBoxAdapter(child: SizedBox(height: 2)),
                      SliverToBoxAdapter(child: CouponList()),
                      SliverToBoxAdapter(child: SizedBox(height: 2)),
                      SliverToBoxAdapter(child: tiffinMenu(context, open)),
                      SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverToBoxAdapter(
                        child: material.Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/logo_dark.png',
                              fit: BoxFit.contain,
                              width: 100,
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 5)),
                      SliverToBoxAdapter(
                        child: material.Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/fssai.png',
                              fit: BoxFit.contain,
                              width: 60,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: material.Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'LIC NO. 22123040000790',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const material.Color.fromARGB(
                                255,
                                86,
                                86,
                                86,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
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
              Positioned(
                bottom: 0,
                child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 80,
                      child: material.Center(child: searchBar(context)),
                    )
                    .animate(
                      target: cartItems.isNotEmpty ? 1 : 0,
                      key: ValueKey(cartItems.isNotEmpty),
                    )
                    .move(
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                      begin: Offset(0, 0),
                      end: Offset(0, -59),
                    ),
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
      bottom: 0,
      child: Visibility(
        visible: cartItems.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 60,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: AppColors.primary),
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
                          (method) => _openCheckout(price, method),
                          () => _handlePayOnDelivery(),
                          loyaltyPoints,
                          ref,
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
  material.Container tiffinMenu(material.BuildContext context, bool open) {
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
              (!open)
                  ? LottieBuilder.asset(
                    'assets/lottie/closed.json',
                    width: MediaQuery.of(context).size.width,
                    renderCache: RenderCache.raster,
                  )
                  : (isLoading)
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
                            padding: const EdgeInsets.only(
                              bottom: 15,
                              left: 15,
                              right: 20,
                            ),
                            child: material.Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Spring roll combination'),
                                    Text('879 ka hai ye'),
                                    Text('879 ka hai ye'),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.cover,
                                      width: 80,
                                    ),
                                  ),
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

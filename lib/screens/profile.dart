import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/address.dart';
import 'package:tiffinwala/providers/addressloaded.dart';
import 'package:tiffinwala/providers/firstname.dart';
import 'package:tiffinwala/providers/lastname.dart';
import 'package:tiffinwala/providers/nameloaded.dart';
import 'package:tiffinwala/providers/points.dart';
import 'package:tiffinwala/screens/address.dart';
import 'package:tiffinwala/screens/auth.dart';
import 'package:tiffinwala/screens/orders.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/details.dart';
import 'package:tiffinwala/utils/setting.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/badge.dart';
import 'package:http/http.dart' as http;

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

List<String> _settings = [
  'Personal Details',
  'Address',
  'Past orders',
  'Log out',
];

Set<IconData> _settingIcons = {
  LucideIcons.user,
  LucideIcons.mapPin,
  LucideIcons.box,
  LucideIcons.logOut,
};

List<Color> _bgColors = [
  Color.fromARGB(255, 255, 192, 33),
  Color.fromARGB(255, 0, 204, 255),
  Color.fromARGB(255, 255, 145, 0),
  Color.fromARGB(255, 153, 153, 153),
];

class _ProfileState extends ConsumerState<Profile> {
  late int loyaltyPoints = 0;
  late String phoneNumber = "";
  late List<dynamic> pastOrders = [];
  late String firstName = "";
  late String lastName = "";
  late String address = "";
  late String phone;
  late String token;

  late bool addressLoading = ref.watch(isAddressLoadedProvider);
  late bool isNameLoading = ref.watch(isNameLoadedProvider);

  Future<void> initSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phone')!;
    token = prefs.getString('token')!;
    phoneNumber = phone;

    ref.read(isAddressLoadedProvider.notifier).setAddressLoaded(true);
    ref.read(isNameLoadedProvider.notifier).setNameLoaded(true);

    if (token.isNotEmpty && phone.isNotEmpty) {
      getLoyaltyPoints(ref);
      getPastOrders();
      getUserData(ref, phone, token);
    }
  }

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

  Future<void> getPastOrders() async {
    var response = await http.get(
      Uri.parse('${BaseUrl.url}/user/orders/$phone'),
      headers: {
        'Content-Type': "application/json",
        "authorization": "Bearer $token",
      },
    );

    var jsonRes = jsonDecode(response.body);

    if (jsonRes['status']) {
      pastOrders = jsonRes['data'];
    }
  }

  Future<void> getUserData(WidgetRef ref, String phone, String token) async {
    var res = await http.get(
      Uri.parse('${BaseUrl.url}/user/$phone'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    var jsonRes = jsonDecode(res.body);
    if (jsonRes['status'] == true) {
      var firstName = jsonRes['data']['firstName'];
      var lastName = jsonRes['data']['lastName'];

      ref.read(setFirstNameProvider.notifier).setFirstName(firstName);
      ref.read(setLastNameProvider.notifier).setLastName(lastName);
      ref.read(isNameLoadedProvider.notifier).setNameLoaded(false);
      ref.read(isAddressLoadedProvider.notifier).setAddressLoaded(false);
    } else {
      log('Failed to fetch user data: ${jsonRes['message']}');
    }
  }

  @override
  void initState() {
    initSharedPreferences();

    super.initState();
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Auth()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyPoints = ref.watch(setPointsProvider);
    final firstName = ref.watch(setFirstNameProvider);
    final lastName = ref.watch(setLastNameProvider);
    final addresses = ref.read(addressProvider);
    final primaryAddress = addresses.firstWhere(
      (a) => a.isPrimary,
      orElse: () => AddressModel(id: '', address: ''),
    );
    addressLoading = ref.watch(isAddressLoadedProvider);
    isNameLoading = ref.watch(isNameLoadedProvider);

    List<String> details = [phoneNumber, 'Loyalty Points'];

    List<VoidCallback> settingFunctions = [
      () => editPersonalDetails(
        context,
        firstName,
        lastName,
        () => getUserData(ref, phone, token),
      ),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddressPage()),
      ),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Orders()),
      ),
      () => logout(context),
    ];

    List<String> detailsValue = ['Joined 1 day ago', loyaltyPoints.toString()];
    return material.Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              TiffinAppBar(centerTitle: true, title: 'Profile'),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VerifiedBadge(),
                      (isNameLoading)
                          ? Skeletonizer(
                            containersColor: AppColors.accent,
                            enableSwitchAnimation: true,
                            enabled: isNameLoading,

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
                            child: Text(
                              'Om Rajpal',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          : Text(
                            "$firstName $lastName",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      SizedBox(height: 4),
                      (addressLoading)
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
                                enabled: addressLoading,
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
                          : Address(address: primaryAddress.address),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 40)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA0A3B0),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: List.generate(2, (index) {
                      return Details(
                        title: details[index],
                        detail: detailsValue[index],
                      );
                    }),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 30)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Additional Settings',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA0A3B0),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xff212121),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(4, (index) {
                      return Setting(
                        index: index,
                        label: _settings[index],
                        onPressed: settingFunctions[index],
                        icon: _settingIcons.elementAt(index),
                        bgcolor: _bgColors[index],
                      );
                    }),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 25)),
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
                    'LIC NO. 2301923745896',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const material.Color.fromARGB(255, 86, 86, 86),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> editPersonalDetails(
  material.BuildContext context,
  String firstName,
  String lastName,
  VoidCallback onPressed,
) {
  return showDialog(
    context: context,
    builder: (context) {
      final FormController controller = FormController();
      return AlertDialog(
        title: const Text(
          'Edit personal details',
          style: TextStyle(fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make changes to your personal details here. Click save when you\'re done',
              style: TextStyle(fontSize: 11.5),
            ),
            const Gap(16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                controller: controller,
                child: FormTableLayout(
                  rows: [
                    FormField<String>(
                      key: FormKey(#firstName),
                      label: Text('First Name', style: TextStyle(fontSize: 12)),
                      child: TextField(
                        initialValue: firstName,
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    FormField<String>(
                      key: FormKey(#lastName),
                      label: Text('Last Name', style: TextStyle(fontSize: 12)),
                      child: TextField(
                        initialValue: lastName,
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ).withPadding(vertical: 16),
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            child: const Text(
              'Save changes',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              List<String> valueList = [];
              final values = controller.values.map((key, value) {
                valueList.add(value);
                return MapEntry(key, value);
              });

              SharedPreferences prefs = await SharedPreferences.getInstance();
              var phone = prefs.getString('phone');
              var token = prefs.getString('token');

              var body = {'firstName': valueList[0], 'lastName': valueList[1]};

              var res = await http.put(
                Uri.parse('${BaseUrl.url}/user/name/$phone'),
                body: jsonEncode(body),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'Bearer $token',
                },
              );

              var jsonRes = jsonDecode(res.body);

              if (!context.mounted) return;

              if (jsonRes['status']) {
                onPressed();
                Navigator.of(context).pop(values);
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to update personal details.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      );
    },
  );
}

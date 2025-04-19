import 'dart:convert';

import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/screens/auth.dart';
import 'package:tiffinwala/screens/orders.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/details.dart';
import 'package:tiffinwala/utils/setting.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/address.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/badge.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
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

class _ProfileState extends State<Profile> {
  late int loyaltyPoints = 0;
  late String phoneNumber = "";
  late List<dynamic> pastOrders = [];
  late String firstName = "";
  late String lastName = "";
  late String address = "";

  Future<void> getLoyaltyPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phone = prefs.getString('phone');
    var token = prefs.getString('token');
    phoneNumber = phone!;
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
    }
  }

  Future<void> getPastOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phone = prefs.getString('phone');
    var token = prefs.getString('token');

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

  Future<void> getUserData() async {
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
      firstName = jsonRes['data']['firstName'];
      lastName = jsonRes['data']['lastName'];
      address = jsonRes['data']['address'];
      setState(() {});
    } else {
      print('Failed to fetch user data: ${jsonRes['message']}');
    }
  }

  @override
  void initState() {
    getLoyaltyPoints();
    getPastOrders();
    getUserData();
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
    List<String> details = [phoneNumber, 'Loyalty Points'];

    List<VoidCallback> settingFunctions = [
      () => editPersonalDetails(context),
      () => editAddress(context),
      () => Navigator.push(context, MaterialPageRoute(builder: (context) => Orders(),)),
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
                      Text(
                        "$firstName $lastName",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Address(address: address,),
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
                        badge: 'Verified',
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
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> editPersonalDetails(material.BuildContext context) {
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
                child: const FormTableLayout(
                  rows: [
                    FormField<String>(
                      key: FormKey(#firstName),
                      label: Text('First Name', style: TextStyle(fontSize: 12)),
                      child: TextField(
                        initialValue: 'John',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    FormField<String>(
                      key: FormKey(#lastName),
                      label: Text('Last Name', style: TextStyle(fontSize: 12)),
                      child: TextField(
                        initialValue: 'Doe',
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
            child: const Text('Save changes'),
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
                body: jsonEncode(body), // pass the updated map
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'Bearer $token',
                },
              );

              var jsonRes = jsonDecode(res.body);

              if (!context.mounted) return;

              if (jsonRes['status']) {
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

Future<dynamic> editAddress(material.BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      final FormController controller = FormController();
      return AlertDialog(
        title: const Text('Edit your address', style: TextStyle(fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make changes to your address here. Click save when you\'re done',
              style: TextStyle(fontSize: 11.5),
            ),
            const Gap(16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                controller: controller,
                child: const FormTableLayout(
                  rows: [
                    FormField<String>(
                      key: FormKey(#address),
                      label: Text('Address', style: TextStyle(fontSize: 12)),
                      child: TextField(
                        initialValue: 'Street xyz, Ottawa, Canada',
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
            child: const Text('Save changes'),
            onPressed: () async {
              var address = "";
              var values = controller.values.map((key, value) {
                address = value;
                return MapEntry(key, value);
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var phone = prefs.getString('phone');
              var token = prefs.getString('token');

              var body = {'address': address};
              var res = await http.put(
                Uri.parse('${BaseUrl.url}/user/address/$phone'),
                headers: {
                  'Content-Type': 'application/json',
                  'authorization': 'Bearer $token',
                },
                body: jsonEncode(body),
              );

              var jsonRes = jsonDecode(res.body);
              if (!context.mounted) return;
              if (jsonRes['status']) {
                Navigator.of(context).pop(values);
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to update address.'),
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

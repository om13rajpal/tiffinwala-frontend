import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/screens/auth.dart';
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

  Future<void> getLoyaltyPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phone = prefs.getString('phone');
    phoneNumber = phone!;
    var response = await http.get(
      Uri.parse('${BaseUrl.url}/user/loyalty/$phone'),
      headers: {'Content-Type': "application/json"},
    );

    var jsonRes = jsonDecode(response.body);
    if (jsonRes['status']) {
      loyaltyPoints = jsonRes['data'];
      setState(() {});
    }
  }

  Future<void> getPastOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phone = prefs.getString('phone');

    var response = await http.get(
      Uri.parse('${BaseUrl.url}/user/orders/$phone'),
      headers: {'Content-Type': "application/json"},
    );

    var jsonRes = jsonDecode(response.body);

    if (jsonRes['status']) {
      pastOrders = jsonRes['data'];
    }
  }

  @override
  void initState() {
    getLoyaltyPoints();
    getPastOrders();
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

    List<String> detailsValue = ['Joined 1 day ago', loyaltyPoints.toString()];
    return Scaffold(
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
                        'Om Rajpal',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Address(),
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
                        onPressed: () => logout(context),
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

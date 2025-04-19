import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/utils/appbar.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

List<dynamic> pastOrders = [];

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
  print(jsonRes);

  if (jsonRes['status']) {
    pastOrders = jsonRes['data'];
  }
}

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    getPastOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          slivers: [
            TiffinAppBar(centerTitle: true, title: 'Past Orders'),
            SliverToBoxAdapter(
              child: Column(
                children: List.generate(pastOrders.length, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: DashedBorder.fromBorderSide(
                        side: const BorderSide(color: Colors.black, width: 0.2),
                        dashLength: 2.5,
                        spaceLength: 2.5,
                      ),
                    ),
                    child: Column(children: [
                        Text(
                          index.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          pastOrders[index]['order'][0]['itemName'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '₹${pastOrders[index]['quantity']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
            
                      ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

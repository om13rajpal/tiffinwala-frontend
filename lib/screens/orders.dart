import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/utils/appbar.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

List<dynamic> pastOrders = [];

/// Fetch past orders from the server and update the state.
Future<void> getPastOrders() async {
  final prefs = await SharedPreferences.getInstance();
  final phone = prefs.getString('phone');
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('${BaseUrl.url}/user/orders/$phone'),
    headers: {
      'Content-Type': "application/json",
      "authorization": "Bearer $token",
    },
  );

  final jsonRes = jsonDecode(response.body);

  if (jsonRes['status'] == true) {
    pastOrders = jsonRes['data'];
  }
}

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    _fetchAndUpdate();
    super.initState();
  }

  Future<void> _fetchAndUpdate() async {
    await getPastOrders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context)
              .copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              TiffinAppBar(centerTitle: true, title: 'Past Orders'),
              SliverToBoxAdapter(
                child: Column(
                  children: List.generate(pastOrders.length, (index) {
                    final orderData = pastOrders[index];
                    final items = List.from(orderData['order']);
                    final totalPrice = orderData['price'];
                    final orderDate = DateTime.parse(orderData['orderDate']);
                    final formattedDate =
                        DateFormat('dd MMM yyyy, hh:mm a').format(orderDate);
                    final paymentMethod = orderData['paymentMethod'];
                    final orderMode = orderData['orderMode'];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 37, 37, 37),

                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date & Total Row
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹$totalPrice',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Items List
                          ...items.map<Widget>((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['shortName']} ×${item['quantity']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text('₹${item['unitPrice']}'),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 20),

                          // Payment & Mode Row
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Payment: $paymentMethod'),
                              Text('Mode: $orderMode'),
                            ],
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
      ),
    );
  }
}
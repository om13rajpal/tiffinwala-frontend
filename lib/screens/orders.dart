import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/utils/appbar.dart';
import 'package:tiffinwala/utils/text and inputs/gradientext.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

List<dynamic> pastOrders = [];

// Fetch past orders from the server and update the state.
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
    if (mounted) setState(() {});
  }

  // Pretty money
  String rs(num v) => '₹${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              const TiffinAppBar(centerTitle: true, title: 'Past Orders'),
              SliverToBoxAdapter(
                child: Column(
                  children: List.generate(pastOrders.length, (index) {
                    final o = pastOrders[index];

                    // Core fields from backend
                    final items = List.from(o['order'] ?? []);
                    final price = (o['price'] ?? 0).toDouble();              // subtotal (items incl. options)
                    final handling = (o['handling'] ?? 0).toDouble();        // packaging
                    final delivery = (o['delivery'] ?? 0).toDouble();        // delivery fee
                    final discount = (o['discount'] ?? 0).toDouble();        // coupon discount (₹)
                    final loyalty = (o['loyalty'] ?? 0).toDouble();          // loyalty discount (₹)
                    final amountPayable =
                        (o['amountPayable'] ?? (price - discount - loyalty + handling + delivery))
                            .toDouble();                                     // fallback compute

                    final couponCode = (o['couponCode'] ?? '').toString();
                    final paymentMethod = (o['paymentMethod'] ?? '').toString();
                    final orderMode = (o['orderMode'] ?? '').toString();
                    final orderDate = DateTime.tryParse(o['orderDate'] ?? '') ?? DateTime.now();
                    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(orderDate);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: const Color.fromARGB(255, 64, 64, 64)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Date & Total (Grand)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              GradientText(text: rs(amountPayable)),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Items List
                          ...items.map<Widget>((item) {
                            final name = (item['shortName'] ?? '').toString();
                            final qty = (item['quantity'] ?? 0) is num
                                ? (item['quantity'] as num).toInt()
                                : int.tryParse('${item['quantity']}') ?? 0;
                            final unit = (item['unitPrice'] ?? 0) is num
                                ? (item['unitPrice'] as num).toDouble()
                                : double.tryParse('${item['unitPrice']}') ?? 0.0;
                            final lineTotal = unit * qty;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$name ×$qty',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color.fromARGB(255, 169, 169, 169),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    rs(lineTotal),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color.fromARGB(255, 169, 169, 169),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 18),

                          // Amount breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Items Subtotal', style: TextStyle(fontSize: 12)),
                              Text(rs(price), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Packaging', style: TextStyle(fontSize: 12)),
                              Text(rs(handling), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery', style: TextStyle(fontSize: 12)),
                              Text(rs(delivery), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          if ((discount + loyalty) > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discounts', style: TextStyle(fontSize: 12)),
                                Text('- ${rs(discount + loyalty)}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],

                          const SizedBox(height: 6),
                          const Divider(height: 18),

                          // Payment & Mode + coupon, neatly
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(LucideIcons.creditCard, size: 12),
                                  SizedBox(width: 4),
                                  // paymentMethod text is on the right side cell
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(LucideIcons.truck, size: 12),
                                  SizedBox(width: 4),
                                  // orderMode text is on the right side cell
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(paymentMethod.toUpperCase(), style: const TextStyle(fontSize: 12)),
                              Text(orderMode.toUpperCase(), style: const TextStyle(fontSize: 12)),
                            ],
                          ),

                          if (couponCode.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white10,
                              ),
                              child: Text('Coupon: $couponCode',
                                  style: const TextStyle(fontSize: 11)),
                            ),
                          ],
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
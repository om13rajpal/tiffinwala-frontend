import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiffinwala/constants/colors.dart';

class CouponList extends StatefulWidget {
  const CouponList({super.key});

  @override
  State<CouponList> createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> {
  List<dynamic> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    final url = Uri.parse('https://api.sixty6foods.in/coupon/');
    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        setState(() {
          coupons =
              (json['data'] as List)
                  .where(
                    (c) => c['enabled'] == true,
                  ) // ✅ filter only enabled coupons
                  .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCouponDialog(Map<String, dynamic> coupon) {
    final expiryDate = DateFormat.yMMMMd().format(
      DateTime.parse(coupon['expiryDate']),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  coupon['code'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 18, color: AppColors.secondary),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: coupon['code'].toString()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Coupon code copied!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.grey[800],
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Copy Code',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon['discount'] is int
                      ? "${coupon['discount']}% off"
                      : coupon['discount'].toString(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Expires on $expiryDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 70,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (coupons.isEmpty) {
      return SizedBox(
        height: 70,
        child: Center(
          child: Text(
            "No coupons found",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: coupons.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final coupon = coupons[index];

          return GestureDetector(
            onTap: () => showCouponDialog(coupon),
            child: Container(
              width: 160,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                // ✅ Darker gradient background
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF40C9),
                    Color(0xFFFF0099),
                    Color(0xFFF7BB97),
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
                borderRadius: BorderRadius.circular(15), // 🔁 keep same
              ),
              child: Center(
                child: Text(
                  coupon['code'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold, // ✅ Make bold
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

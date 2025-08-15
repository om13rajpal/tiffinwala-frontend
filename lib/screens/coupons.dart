import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:tiffinwala/constants/url.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  bool loading = true;
  List<dynamic> coupons = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Use your BaseUrl to keep environments consistent
      final url = Uri.parse("${BaseUrl.url}/coupon/");
      final res = await http.get(url);
      final jsonRes = jsonDecode(res.body);

      if (res.statusCode == 200 && jsonRes['status'] == true) {
        // only enabled coupons
        final list =
            (jsonRes['data'] as List)
                .where((c) => c['enabled'] == true)
                .toList();

        setState(() {
          coupons = list;
          loading = false;
        });
      } else {
        setState(() {
          error = jsonRes['message']?.toString() ?? 'Failed to load coupons';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Something went wrong. Please try again.';
        loading = false;
      });
    }
  }

  String _discountText(dynamic d) {
    if (d is int || d is double) return '${d}% off';
    return d?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101012),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101012),
        elevation: 0,
        title: const Text(
          'Available Coupons',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _fetchCoupons,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : coupons.isEmpty
              ? const Center(
                child: Text(
                  'No coupons found',
                  style: TextStyle(color: Colors.white54),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, idx) {
                  final c = coupons[idx];
                  final code = (c['code'] ?? '').toString();
                  final discount = _discountText(c['discount']);
                  final expiry =
                      c['expiryDate'] != null
                          ? DateFormat.yMMMEd().format(
                            DateTime.parse(c['expiryDate']),
                          )
                          : '—';

                  return InkWell(
                    onTap: () {
                      // pop back the selected code
                      Navigator.pop(context, code);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1B1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        code,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        discount,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.white38,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Expires: $expiry',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white60,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: coupons.length,
              ),
    );
  }
}

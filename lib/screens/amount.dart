import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/screens/success.dart';

class UserPaymentScreen extends StatefulWidget {
  final String merchantId;

  const UserPaymentScreen({super.key, required this.merchantId});

  @override
  State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  String phone = "";
  int balance = 0;
  String amount = "";
  bool loading = false;

  final Color tiffinWalaPurple = Color(0xFF780078);
  final Color lighterPurple = Color(0xFFA02AA0);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phone') ?? "";

    if (phone.isNotEmpty) {
      final response = await http.get(
        Uri.parse(
          "https://merchant.tiffinwala.services/user/balance?phone=$phone",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          balance = data["loyaltyPoints"] ?? 0;
        });
      }
    }
  }

  void addDigit(String digit) {
    setState(() {
      amount += digit;
    });
  }

  void deleteDigit() {
    if (amount.isNotEmpty) {
      setState(() {
        amount = amount.substring(0, amount.length - 1);
      });
    }
  }

  Future<void> pay() async {
    if (amount.isEmpty || int.tryParse(amount) == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter an amount")));
      return;
    }

    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("https://merchant.tiffinwala.services/transaction"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userPhone": phone,
        "merchantId": widget.merchantId,
        "amount": int.parse(amount),
      }),
    );

    setState(() => loading = false);

    final data = jsonDecode(response.body);
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => Success(
                title: "Payment Successful",
                message: data["message"] ?? "Your payment was successful.",
                details: {
                  "Merchant ID": widget.merchantId,
                },
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"] ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool payEnabled = amount.isNotEmpty && int.tryParse(amount) != 0;

    return Scaffold(
      backgroundColor: tiffinWalaPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      LucideIcons.arrowUpLeft,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: lighterPurple, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Balance ₹$balance",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: Text(
                  "₹${amount.isEmpty ? "0" : amount}",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: lighterPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "Merchant ID: ${widget.merchantId}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    String label;
                    if (index < 9) {
                      label = '${index + 1}';
                    } else if (index == 9) {
                      label = ".";
                    } else if (index == 10) {
                      label = "0";
                    } else {
                      label = "<";
                    }

                    return InkWell(
                      onTap: () {
                        if (label == "<") {
                          deleteDigit();
                        } else if (label != ".") {
                          addDigit(label);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              loading
                  ? Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: payEnabled ? pay : null,
                      style: ElevatedButton.styleFrom(
                        elevation: payEnabled ? 2 : 0,
                        backgroundColor:
                            payEnabled
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: payEnabled ? tiffinWalaPurple : Colors.white70,
                        ),
                      ),
                    ),
                  ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

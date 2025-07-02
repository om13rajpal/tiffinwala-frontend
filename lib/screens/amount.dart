import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
        Uri.parse("http://localhost:5000/user/balance?phone=$phone"),
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
    if (amount.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter an amount")));
      return;
    }

    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("http://localhost:5000/transaction"),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Payment Successful")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"] ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE91E63),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Available Balance",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "₹$balance",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "₹${amount.isEmpty ? "0" : amount}",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
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

                    return ElevatedButton(
                      onPressed: () {
                        if (label == "<") {
                          deleteDigit();
                        } else if (label != ".") {
                          addDigit(label);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Pay",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
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

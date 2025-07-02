import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tiffinwala/screens/amount.dart';

class UserScannerScreen extends StatefulWidget {
  const UserScannerScreen({super.key});

  @override
  State<UserScannerScreen> createState() => _UserScannerScreenState();
}

class _UserScannerScreenState extends State<UserScannerScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Merchant QR", style: TextStyle(fontSize: 14),)),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (!isScanned && barcodes.isNotEmpty) {
            final String? rawValue = barcodes.first.rawValue;
            if (rawValue != null && rawValue.contains("merchantid")) {
              final uri = Uri.tryParse(rawValue);
              if (uri != null) {
                final merchantId = uri.queryParameters["merchantid"];
                if (merchantId != null) {
                  isScanned = true;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserPaymentScreen(
                        merchantId: merchantId,
                      ),
                    ),
                  );
                }
              }
            }
          }
        },
      ),
    );
  }
}
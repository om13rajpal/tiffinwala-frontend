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
      appBar: AppBar(
        title: Text("Scan Merchant QR", style: TextStyle(fontSize: 14)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(autoZoom: true),
            onDetect: (BarcodeCapture capture) {
              if (isScanned) return;
              final codes = capture.barcodes;
              if (codes.isEmpty) return;

              final rawValue = codes.first.rawValue;
              if (rawValue == null) return;

              String? merchantId;

              // A) Plain code like "MERCHANT1751719661366"
              final plainId = RegExp(
                r'^MERCHANT[0-9A-Z]+$',
                caseSensitive: false,
              );
              if (plainId.hasMatch(rawValue)) {
                merchantId = rawValue;
              } else {
                // B) Try parse as URL
                final uri = Uri.tryParse(rawValue);

                // Helper to read merchantId in ANY case
                String? getParamCaseInsensitive(Uri u, String key) {
                  for (final entry in u.queryParameters.entries) {
                    if (entry.key.toLowerCase() == key.toLowerCase())
                      return entry.value;
                  }
                  return null;
                }

                if (uri != null) {
                  // B1) If this is a Firebase Dynamic Link, the real link is in ?link=...
                  final deepLinkStr =
                      getParamCaseInsensitive(uri, "link") ?? rawValue;
                  final deepUri = Uri.tryParse(deepLinkStr);

                  if (deepUri != null) {
                    merchantId =
                        getParamCaseInsensitive(deepUri, "merchantId") ??
                        getParamCaseInsensitive(deepUri, "merchantid");
                  }
                }
              }

              if (merchantId != null && merchantId.isNotEmpty) {
                isScanned = true;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserPaymentScreen(merchantId: merchantId!),
                  ),
                );
              }
            },
          ),
          const ScannerOverlay(),
        ],
      ),
    );
  }
}

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double overlayWidth = constraints.maxWidth;
        final double overlayHeight = constraints.maxHeight;
        final double boxSize = overlayWidth * 0.65;
        final double left = (overlayWidth - boxSize) / 2;
        final double top = (overlayHeight - boxSize) / 2;
        final double scanLineWidth = boxSize * 0.85;
        final double scanLineLeft = left + (boxSize - scanLineWidth) / 2;

        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    width: overlayWidth,
                    height: overlayHeight,
                    color: Colors.black,
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: CustomPaint(
                size: Size(boxSize, boxSize),
                painter: RoundedCornerPainter(),
              ),
            ),
            Positioned(
              left: scanLineLeft,
              top: top,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value * (boxSize - 4)),
                    child: Container(
                      width: scanLineWidth,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Align QR code within the frame",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RoundedCornerPainter extends CustomPainter {
  final double length = 30;
  final double strokeWidth = 6;
  final Color color = Color(0xFF6A1B9A);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    // Top left
    canvas.drawArc(
      Rect.fromLTWH(0, 0, length * 2, length * 2),
      3.14159,
      1.5708,
      false,
      paint,
    );

    // Top right
    canvas.drawArc(
      Rect.fromLTWH(size.width - length * 2, 0, length * 2, length * 2),
      -1.5708,
      1.5708,
      false,
      paint,
    );

    // Bottom right
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - length * 2,
        size.height - length * 2,
        length * 2,
        length * 2,
      ),
      0,
      1.5708,
      false,
      paint,
    );

    // Bottom left
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - length * 2, length * 2, length * 2),
      1.5708,
      1.5708,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

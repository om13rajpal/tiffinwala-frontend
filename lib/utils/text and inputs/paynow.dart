import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/cart.dart';
import 'package:tiffinwala/providers/coupon.dart';
import 'package:tiffinwala/providers/discount.dart';
import 'package:tiffinwala/screens/coupons.dart';
import 'package:tiffinwala/screens/payment.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/buttons/checkbox.dart';
import 'package:http/http.dart' as http;

final coldDrinkProvider = StateProvider<bool>((ref) => false);
final chocolateMousseProvider = StateProvider<bool>((ref) => false);

class Paynow extends ConsumerStatefulWidget {
  final void Function(String method)? openCheckout;
  final VoidCallback cod;
  final int loyaltyPoints;
  final double totalPrice;

  const Paynow(this.openCheckout, this.loyaltyPoints, this.cod, this.totalPrice, {super.key});

  @override
  ConsumerState<Paynow> createState() => _PaynowState();
}

TextEditingController coupon = TextEditingController();

class _PaynowState extends ConsumerState<Paynow> {
  bool verifying = false;

  // ---------- Helpers for BOGO family (FIXED, consistent snapshots) ----------

  // Treat originalPrice as a snapshot of the *line total* (qty included).
  double _baseLineTotalOf(CartItems it) {
    final hasSnapshot = it.originalPrice is num;
    return hasSnapshot ? (it.originalPrice as num).toDouble() : it.totalPrice;
  }

  double _unitFromLine(CartItems it) {
    final qty = it.quantity > 0 ? it.quantity : 1;
    final baseLine = _baseLineTotalOf(it);
    return baseLine / qty;
  }

  /// Restore each line to its pre-discount line total (if we have a snapshot),
  /// then clear the snapshot to prevent compounding on subsequent applies.
  void _restoreCartTotals(WidgetRef ref) {
    final cart = ref.read(cartProvider);
    final restored = cart.map((it) {
      final hasSnapshot = it.originalPrice is num;
      final line = hasSnapshot ? (it.originalPrice as num).toDouble() : it.totalPrice;
      return CartItems(
        it.item,
        line,                  // restore clean line total
        it.options,
        it.quantity,
        it.optionSet,
        originalPrice: null,   // clear snapshot to avoid drift
      );
    }).toList();

    ref.read(cartProvider.notifier).state = restored;
  }

  /// Apply exactly one free unit on the *cheapest* line when eligible.
  /// We snapshot *every* line’s pre-discount line total into originalPrice,
  /// then reduce the chosen line’s total by one unit.
  void _applySingleFreeUnitForBOGOFamily(WidgetRef ref, int requiredQty) {
    final cart = ref.read(cartProvider);
    final totalQty = cart.fold<int>(0, (s, i) => s + i.quantity);
    if (totalQty < requiredQty + 1) return;

    // Find cheapest unit
    CartItems? cheapest;
    double cheapestUnit = double.infinity;
    for (final it in cart) {
      final unit = _unitFromLine(it);
      if (unit > 0 && unit < cheapestUnit) {
        cheapestUnit = unit;
        cheapest = it;
      }
    }
    if (cheapest == null) return;

    final updated = cart.map((it) {
      final baseLine = _baseLineTotalOf(it);  // snapshot source

      if (identical(it, cheapest)) {
        final unit = _unitFromLine(it);
        final newLine = (baseLine - unit).clamp(0.0, double.infinity);
        return CartItems(
          it.item,
          newLine,             // discounted line total (one unit off)
          it.options,
          it.quantity,
          it.optionSet,
          originalPrice: baseLine, // snapshot pre-discount line total
        );
      }

      // Non-cheapest lines: snapshot only (no change to total)
      return CartItems(
        it.item,
        baseLine,
        it.options,
        it.quantity,
        it.optionSet,
        originalPrice: baseLine,
      );
    }).toList();

    ref.read(cartProvider.notifier).state = updated;
  }

  // ---------- Loyalty checkbox ----------

  void handleCheckbox(bool isChecked) {
    if (isChecked) {
      ref.read(discountProvider.notifier).setLoyaltyDiscount(widget.loyaltyPoints.toDouble());
    } else {
      ref.read(discountProvider.notifier).setLoyaltyDiscount(0.0);
    }
  }

  // ---------- Coupon logic ----------

  Future<void> _verifyCouponWithCode(String code) async {
    if (code.trim().isEmpty) return;

    setState(() {
      verifying = true;
    });

    final body = {"code": code.trim(), "price": widget.totalPrice};

    try {
      final response = await http.post(
        Uri.parse("${BaseUrl.url}/coupon/verifyCoupon"),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );

      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        double discount = 0;
        final discountValue = jsonRes["data"]["discount"];
        if (discountValue is int) {
          discount = discountValue.toDouble();
        } else if (discountValue is double) {
          discount = discountValue;
        }

        final codeUpper = code.trim().toUpperCase();

        // Always start clean so re-applying the same coupon doesn’t compound
        _restoreCartTotals(ref);

        if (codeUpper == "BOGO" || codeUpper == "B2G1" || codeUpper == "B3G1") {
          int requiredQty = 1;
          if (codeUpper == "B2G1") requiredQty = 2;
          if (codeUpper == "B3G1") requiredQty = 3;

          final cartItems = ref.read(cartProvider);
          final totalQty = cartItems.fold(0, (sum, item) => sum + item.quantity);
          if (totalQty >= requiredQty + 1) {
            _applySingleFreeUnitForBOGOFamily(ref, requiredQty);
          } else {
            removeCoupon();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Not enough items for this offer.", style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red.shade700,
              ),
            );
            return;
          }
        }

        // Conditional freebies (flags only; UI can read these)
        if (codeUpper == "COLDDRINK" && widget.totalPrice >= 179) {
          ref.read(coldDrinkProvider.notifier).state = true;
        }
        if (codeUpper == "SWEET" && widget.totalPrice >= 249) {
          ref.read(chocolateMousseProvider.notifier).state = true;
        }

        // % discount stored (your getPayableAmount should use this)
        ref.read(discountProvider.notifier).setCouponDiscount(discount);
        ref.read(couponProvider.notifier).setCoupon(discount.toInt(), codeUpper);

        // Update text field (locked once applied)
        coupon.text = codeUpper;

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Coupon applied successfully!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
          ),
        );
        setState(() {});
      } else {
        removeCoupon();
        final errorMsg = jsonRes["message"] ?? "Failed to apply coupon.";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error verifying coupon. Please try again.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          verifying = false;
        });
      }
    }
  }

  Future<void> verifyCoupon() async {
    await _verifyCouponWithCode(coupon.text);
  }

  void removeCoupon() {
    ref.read(discountProvider.notifier).setCouponDiscount(0.0);
    ref.read(couponProvider.notifier).reset();
    ref.read(coldDrinkProvider.notifier).state = false;
    ref.read(chocolateMousseProvider.notifier).state = false;

    // Fully restore (uses snapshot, then clears it)
    _restoreCartTotals(ref);

    coupon.clear();
    setState(() {});
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final discountState = ref.watch(discountProvider);
    final couponUsed = ref.watch(couponProvider).verified;
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    // If user reduces quantity below eligibility after applying BOGO family, remove it
    final couponCode = ref.read(couponProvider).code;
    if ((couponCode == "BOGO" || couponCode == "B2G1" || couponCode == "B3G1")) {
      int requiredQty = 1;
      if (couponCode == "B2G1") requiredQty = 2;
      if (couponCode == "B3G1") requiredQty = 3;

      int totalQty = cartItems.fold(0, (sum, item) => sum + item.quantity);
      if (totalQty < requiredQty + 1) {
        Future.microtask(() => removeCoupon());
      }
    }

    final totalPayable = cartNotifier.getPayableAmount(
      ref,
      couponPercent: discountState.couponDiscount,
      loyaltyPoints: discountState.loyaltyDiscount,
    );

    final loyaltyApplied = discountState.loyaltyDiscount > 0;

    Future<void> openCouponsPage() async {
      final selected = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const CouponsPage()),
      );
      if (selected != null && selected.isNotEmpty) {
        await _verifyCouponWithCode(selected);
      }
    }

    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: SizedBox(
                height: 35,
                child: TextField(
                  controller: couponUsed ? TextEditingController(text: coupon.text) : coupon,
                  readOnly: couponUsed,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 9),
                    hintText: 'Coupon',
                    hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.secondary.withAlpha(100)),
                    filled: true,
                    fillColor: AppColors.accent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(LucideIcons.badgePercent, size: 16),
                    // Right icon behavior:
                    // - Arrow: open coupons page
                    // - X: remove coupon
                    suffixIcon: verifying
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : couponUsed
                            ? InkWell(onTap: removeCoupon, child: const Icon(LucideIcons.x, size: 16))
                            : InkWell(onTap: openCouponsPage, child: const Icon(LucideIcons.chevronRight, size: 16)),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text('Use loyalty points', style: TextStyle(fontSize: 10)),
                Transform.translate(
                  offset: const Offset(-7, 0),
                  child: Row(
                    children: [
                      TiffinCheckbox(preChecked: loyaltyApplied, onChanged: handleCheckbox),
                      Text('₹${widget.loyaltyPoints} off', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${cartItems.length} items in cart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.secondary)),
                Text('₹ ${totalPayable.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.secondary)),
              ],
            ),
            TiffinButton(
              label: 'PAYMENT',
              width: 75,
              height: 27,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(openCheckout: widget.openCheckout, cod: widget.cod),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Coupon {
  bool verified;
  int discount;

  Coupon(this.verified, this.discount);
}

class CouponNotifier extends StateNotifier<Coupon> {
  CouponNotifier() : super(Coupon(false, 0));

  void setCoupon(int discount) {
    state.verified = true;
    state.discount = discount;
  }

  void reset() {
    state.verified = false;
    state.discount = 0;
  }

  int getDiscount() {
    return state.discount;
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, Coupon>(
  (ref) => CouponNotifier(),
);

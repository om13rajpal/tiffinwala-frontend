import 'package:flutter_riverpod/flutter_riverpod.dart';

class Coupon {
  bool verified;
  int discount;
  String code;

  Coupon(this.verified, this.discount, this.code);
}

class CouponNotifier extends StateNotifier<Coupon> {
  CouponNotifier() : super(Coupon(false, 0, ""));

  void setCoupon(int discount, String code) {
    state.verified = true;
    state.discount = discount;
    state.code = code;
  }

  void reset() {
    state.verified = false;
    state.discount = 0;
    state.code = "";
  }

  int getDiscount() {
    return state.discount;
  }

  String getCoupon() {
    return state.code;
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, Coupon>(
  (ref) => CouponNotifier(),
);

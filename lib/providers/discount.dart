import 'package:flutter_riverpod/flutter_riverpod.dart';

class Discount {
  final double loyaltyDiscount;
  final double couponDiscount;

  Discount({this.loyaltyDiscount = 0.0, this.couponDiscount = 0.0});
}

final discountProvider = StateNotifierProvider<DiscountNotifier, Discount>((
  ref,
) {
  return DiscountNotifier();
});

class DiscountNotifier extends StateNotifier<Discount> {
  DiscountNotifier() : super(Discount());

  void setLoyaltyDiscount(double discount) {
    state = Discount(
      loyaltyDiscount: discount,
      couponDiscount: state.couponDiscount,
    );
  }

  void setCouponDiscount(double discount) {
    state = Discount(
      loyaltyDiscount: state.loyaltyDiscount,
      couponDiscount: discount,
    );
  }

  void resetDiscounts() {
    state = Discount();
  }

  double getTotalDiscount() {
    return state.loyaltyDiscount + state.couponDiscount;
  }

  double getLoyaltyDiscount() {
    return state.loyaltyDiscount;
  }

  double getCouponDiscount() {
    return state.couponDiscount;
  }

  bool hasDiscount() {
    return state.loyaltyDiscount > 0 || state.couponDiscount > 0;
  }
}

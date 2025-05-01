import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsUsingLoyalty extends StateNotifier<bool> {
  IsUsingLoyalty() : super(false);

  void setLoading(bool value) {
    state = value;
  }
}

final isUsingLoyaltyProvider = StateNotifierProvider<IsUsingLoyalty, bool>((ref) {
  return IsUsingLoyalty();
});

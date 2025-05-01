import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressNotifier extends StateNotifier<String> {
  AddressNotifier() : super("");

  void setAddress(String value) {
    state = value;
  }
}

final setAddressProvider = StateNotifierProvider<AddressNotifier, String>((ref) {
  return AddressNotifier();
});

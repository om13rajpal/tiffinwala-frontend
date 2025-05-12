import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsAddressLoaded extends StateNotifier<bool> {
  IsAddressLoaded() : super(true);

  void setAddressLoaded(bool value) {
    state = value;
  }
}

final isAddressLoadedProvider = StateNotifierProvider<IsAddressLoaded, bool>((ref) {
  return IsAddressLoaded();
});

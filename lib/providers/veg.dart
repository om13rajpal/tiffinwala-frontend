import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsVegNotifier extends StateNotifier<bool> {
  IsVegNotifier() : super(false);

  void setVeg(bool value) {
    state = value;
  }
}

final isVegProvider = StateNotifierProvider<IsVegNotifier, bool>((ref) {
  return IsVegNotifier();
});

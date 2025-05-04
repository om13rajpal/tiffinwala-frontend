import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsMenuLoaded extends StateNotifier<bool> {
  IsMenuLoaded() : super(true);

  void setMenu(bool value) {
    state = value;
  }
}

final isMenuLoadedProvider = StateNotifierProvider<IsMenuLoaded, bool>((ref) {
  return IsMenuLoaded();
});

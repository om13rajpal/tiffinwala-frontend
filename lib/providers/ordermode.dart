import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeNotifier extends StateNotifier<String> {
  ModeNotifier() : super("Delivery");

  void setOrderMode(String value) {
    state = value;
  }
}

final setOrderModeProvider = StateNotifierProvider<ModeNotifier, String>((ref) {
  return ModeNotifier();
});

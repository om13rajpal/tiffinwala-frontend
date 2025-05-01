import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirstNotifier extends StateNotifier<String> {
  FirstNotifier() : super("");

  void setFirstName(String value) {
    state = value;
  }
}

final setFirstNameProvider = StateNotifierProvider<FirstNotifier, String>((ref) {
  return FirstNotifier();
});

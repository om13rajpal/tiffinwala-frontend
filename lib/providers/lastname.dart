import 'package:flutter_riverpod/flutter_riverpod.dart';

class LastNotifier extends StateNotifier<String> {
  LastNotifier() : super("");

  void setLastName(String value) {
    state = value;
  }
}

final setLastNameProvider = StateNotifierProvider<LastNotifier, String>((ref) {
  return LastNotifier();
});

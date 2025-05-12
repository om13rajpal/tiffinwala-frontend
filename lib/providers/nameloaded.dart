import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsNameLoaded extends StateNotifier<bool> {
  IsNameLoaded() : super(true);

  void setNameLoaded(bool value) {
    state = value;
  }
}

final isNameLoadedProvider = StateNotifierProvider<IsNameLoaded, bool>((ref) {
  return IsNameLoaded();
});

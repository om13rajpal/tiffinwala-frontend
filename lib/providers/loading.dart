import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsLoadingNotifier extends StateNotifier<bool> {
  IsLoadingNotifier() : super(false);

  void setLoading(bool value) {
    state = value;
  }
}

final isLoadingProvider = StateNotifierProvider<IsLoadingNotifier, bool>((ref) {
  return IsLoadingNotifier();
});

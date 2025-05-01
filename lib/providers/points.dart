import 'package:flutter_riverpod/flutter_riverpod.dart';

class PointsNotifier extends StateNotifier<int> {
  PointsNotifier() : super(0);

  void setPoints(int value) {
    state = value;
  }
}

final setPointsProvider = StateNotifierProvider<PointsNotifier, int>((ref) {
  return PointsNotifier();
});
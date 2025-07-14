import 'package:flutter_riverpod/flutter_riverpod.dart';

final chargesProvider = StateProvider<Map<String, double>>(
  (ref) => {'packagingCharge': 6.0, 'deliveryCharge': 10.0},
);

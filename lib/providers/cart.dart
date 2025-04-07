import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final dynamic item;
  final double totalPrice;
  final List<dynamic> options;
  final int quantity;

  CartItem(this.item, this.totalPrice, this.options, this.quantity);
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    state = [...state, item];
  }
}

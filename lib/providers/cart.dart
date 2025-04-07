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

  void addItem(
    dynamic item,
    double totalPrice,
    List<dynamic> options,
    int quantity,
  ) {
    final cartItem = CartItem(item, totalPrice, options, quantity);
    state = [...state, cartItem];
  }

  void removeItem(dynamic item) {
    state = state.where((cartItem) => cartItem.item != item).toList();
  }

  void decrementCart(dynamic item) {
    final index = state.indexWhere((cartItem) => cartItem.item == item);
    if (index != -1) {
      final cartItem = state[index];
      if (cartItem.quantity > 1) {
        final updatedItem = CartItem(
          cartItem.item,
          cartItem.totalPrice,
          cartItem.options,
          cartItem.quantity - 1,
        );
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      } else {
        removeItem(item);
      }
    }
  }

  void incrementCart(dynamic item) {
    final index = state.indexWhere((cartItem) => cartItem.item == item);
    if (index != -1) {
      final cartItem = state[index];
      final updatedItem = CartItem(
        cartItem.item,
        cartItem.totalPrice,
        cartItem.options,
        cartItem.quantity + 1,
      );
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

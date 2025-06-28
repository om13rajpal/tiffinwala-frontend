import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItems {
  final dynamic item;
  final double totalPrice;
  final List<dynamic> options;
  final int quantity;

  CartItems(this.item, this.totalPrice, this.options, this.quantity);
}

class CartNotifier extends StateNotifier<List<CartItems>> {
  CartNotifier() : super([]);

  void addItem(
    dynamic item,
    double totalPrice,
    List<dynamic> options,
    int quantity,
  ) {
    final cartItem = CartItems(item, totalPrice, options, quantity);
    state = [...state, cartItem];
  }

  void removeItem(dynamic item) {
    state =
        state
            .where((cartItem) => cartItem.item['itemName'] != item['itemName'])
            .toList();
  }

  void decrementCart(dynamic item) {
    final index = state.indexWhere(
      (cartItem) => cartItem.item['itemName'] == item['itemName'],
    );
    if (index != -1) {
      final cartItem = state[index];
      if (cartItem.quantity > 1) {
        final updatedItem = CartItems(
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
    final index = state.indexWhere(
      (cartItem) => cartItem.item['itemName'] == item['itemName'],
    );
    if (index != -1) {
      final cartItem = state[index];
      final updatedItem = CartItems(
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

  double getNormalTotalPrice() {
    double total = 0.0;
    for (var item in state) {
      total += item.totalPrice * item.quantity;
    }
    return total;
  }

double getPayableAmount(double couponPercent, double loyaltyPoints) {
    double deliveryFee = 20;
    double subtotal = 0.0;

    for (var item in state) {
      subtotal += item.totalPrice * item.quantity;
    }

    subtotal = subtotal - (subtotal * couponPercent / 100);

    subtotal = subtotal - loyaltyPoints;

    if (subtotal < 0) subtotal = 0;

    double tax = subtotal * 0.05;

    double total = subtotal + tax + deliveryFee;
    return total;
}

  bool itemExists(dynamic item) {
    return state.any(
      (cartItem) => cartItem.item['itemName'] == item['itemName'],
    );
  }

  int quantityCount(dynamic item) {
    final index = state.indexWhere(
      (cartItem) => cartItem.item['itemName'] == item['itemName'],
    );
    if (index != -1) {
      return state[index].quantity;
    }
    return 0;
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItems>>(
  (ref) => CartNotifier(),
);

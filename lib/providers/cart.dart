import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItems {
  final dynamic item;
  final double totalPrice;
  final List<dynamic> options;
  final int quantity;
  final List<dynamic> optionSet;

  CartItems(
    this.item,
    this.totalPrice,
    this.options,
    this.quantity,
    this.optionSet,
  );
}

class CartNotifier extends StateNotifier<List<CartItems>> {
  CartNotifier() : super([]);

  void addItem(
    dynamic item,
    double totalPrice,
    List<dynamic> options,
    int quantity,
    List<dynamic> optionSet, 
  ) {
    final existingIndex = state.indexWhere(
      (cartItem) =>
          cartItem.item['itemName'] == item['itemName'] &&
          _compareOptions(cartItem.options, options),
    );

    if (existingIndex != -1) {
      final existingItem = state[existingIndex];
      final updatedItem = CartItems(
        existingItem.item,
        existingItem.totalPrice,
        existingItem.options,
        existingItem.quantity + quantity,
        existingItem.optionSet,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      final cartItem = CartItems(
        item,
        totalPrice,
        options,
        quantity,
        optionSet,
      );
      state = [...state, cartItem];
    }
  }

  void removeItem(dynamic item, List<dynamic> options) {
    state = state
        .where(
          (cartItem) =>
              !(cartItem.item['itemName'] == item['itemName'] &&
                _compareOptions(cartItem.options, options)),
        )
        .toList();
  }

  void decrementCart(dynamic item, List<dynamic> options) {
    final index = state.indexWhere(
      (cartItem) =>
          cartItem.item['itemName'] == item['itemName'] &&
          _compareOptions(cartItem.options, options),
    );
    if (index != -1) {
      final cartItem = state[index];
      if (cartItem.quantity > 1) {
        final updatedItem = CartItems(
          cartItem.item,
          cartItem.totalPrice,
          cartItem.options,
          cartItem.quantity - 1,
          cartItem.optionSet, 
        );
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      } else {
        removeItem(item, options);
      }
    }
  }

  void incrementCart(dynamic item, List<dynamic> options) {
    final index = state.indexWhere(
      (cartItem) =>
          cartItem.item['itemName'] == item['itemName'] &&
          _compareOptions(cartItem.options, options),
    );
    if (index != -1) {
      final cartItem = state[index];
      final updatedItem = CartItems(
        cartItem.item,
        cartItem.totalPrice,
        cartItem.options,
        cartItem.quantity + 1,
        cartItem.optionSet,
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

  bool _compareOptions(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (final opt in a) {
      if (!b.any(
        (o) =>
            o['optionName'] == opt['optionName'] &&
            o['price'] == opt['price'],
      )) {
        return false;
      }
    }
    return true;
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItems>>(
  (ref) => CartNotifier(),
);
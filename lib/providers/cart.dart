import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/providers/charge.dart';

class CartItems {
  final dynamic item;
  final double totalPrice;
  final double originalPrice;
  final List<dynamic> options;
  final int quantity;
  final List<dynamic> optionSet;

  CartItems(
    this.item,
    this.totalPrice,
    this.options,
    this.quantity,
    this.optionSet, {
    double? originalPrice,
  }) : originalPrice = originalPrice ?? totalPrice;
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
    state =
        state
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

  int getTotalQuantity() {
    int total = 0;
    for (final item in state) {
      total += item.quantity;
    }
    return total;
  }

  double getPayableAmount(
    WidgetRef ref, {
    double couponPercent = 0.0,
    double loyaltyPoints = 0.0,
  }) {
    final charges = ref.read(chargesProvider);

    final double deliveryFee = charges['deliveryCharge'] ?? 10.0;
    final double packagingChargeRate = charges['packagingCharge'] ?? 6.0;

    double subtotal = 0.0;
    int totalItems = 0;

    for (var item in state) {
      subtotal += item.totalPrice * item.quantity;
      totalItems += item.quantity;
    }

    // Apply coupon discount
    subtotal -= subtotal * (couponPercent / 100);

    // Deduct loyalty points
    subtotal -= loyaltyPoints;

    if (subtotal < 0) subtotal = 0;

    final packagingFee = totalItems * packagingChargeRate;

    final total = subtotal + deliveryFee + packagingFee;

    return total;
  }

  bool _compareOptions(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (final opt in a) {
      if (!b.any(
        (o) =>
            o['optionName'] == opt['optionName'] && o['price'] == opt['price'],
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

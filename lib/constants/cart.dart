class CartItem {
  final dynamic item;
  final double totalPrice;
  final List<dynamic> options;
  final int quantity;

  CartItem(this.item, this.totalPrice, this.options, this.quantity);
}

class Cart {
  static List<CartItem> items = [];
}

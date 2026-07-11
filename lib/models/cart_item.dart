class CartItem {
  final int productId;
  final String productName;
  double unitPrice;
  int quantity;
  final String? photoPath;

  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.photoPath,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toTransactionItem(int transactionId) {
    return {
      'transactionId': transactionId,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
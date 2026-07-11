import '../database/db_helper.dart';
import '../models/cart_item.dart';
import '../services/firestore_service.dart';
import '../utils/notification_helper.dart';

class TransactionService {
  final DbHelper _dbHelper = DbHelper();

  /// Perform a checkout atomically.
  /// Returns a Map with 'success' (bool), 'message' (String).
  Future<Map<String, dynamic>> checkout({
    required String buyerUsername,
    required List<CartItem> cartItems,
    required double totalAmount,
  }) async {
    if (cartItems.isEmpty) {
      return {'success': false, 'message': 'Keranjang belanja kosong'};
    }

    final db = await _dbHelper.database;
    String? errorMessage;

    try {
      await db.transaction((txn) async {
        // Step 1: Re-check stock for all items
        for (final item in cartItems) {
          final result = await txn.query(
            'products',
            columns: ['id', 'stock', 'name'],
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          if (result.isEmpty) {
            errorMessage = 'Produk "${item.productName}" tidak ditemukan';
            throw Exception('rollback');
          }

          final currentStock = result.first['stock'] as int;
          if (currentStock < item.quantity) {
            errorMessage =
                'Stok "${item.productName}" tidak mencukupi (tersedia: $currentStock, diminta: ${item.quantity})';
            throw Exception('rollback');
          }
        }

        // Step 2: Insert transaction
        final transactionData = {
          'buyerUsername': buyerUsername,
          'totalAmount': totalAmount,
          'status': 'completed',
          'createdAt': DateTime.now().toIso8601String(),
        };
        final transactionId = await txn.insert('transactions', transactionData);

        // Step 3: Insert transaction items and decrement stock
        for (final item in cartItems) {
          final txnItem = item.toTransactionItem(transactionId);
          await txn.insert('transaction_items', txnItem);

          await txn.rawUpdate(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [item.quantity, item.productId],
          );
        }
      });

      // If we get here without exception, success
      // Push to Firestore if available (Feature 8)
      try {
        final firestoreService = FirestoreService();
        await firestoreService.init();
        final lastTxn = await _dbHelper.getAllTransactions();
        if (lastTxn.isNotEmpty) {
          final txnId = lastTxn.first['id'] as int;
          await firestoreService.pushTransaction({
            'id': txnId,
            'buyerUsername': buyerUsername,
            'totalAmount': totalAmount,
            'items': cartItems.map((e) => e.toTransactionItem(txnId)).toList(),
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      } catch (_) {
        // Firestore sync failure is non-critical
      }

      // Check low stock and trigger notification
      for (final item in cartItems) {
        try {
          final product = await _dbHelper.getProductById(item.productId);
          if (product != null) {
            if (product.stock > 0 && product.stock <= (product.initialStock * 0.1)) {
              NotificationHelper.showLowStockNotification(
                product.name,
                product.stock,
                product.initialStock,
              );
            }
          }
        } catch (_) {}
      }

      // Trigger realtime order notification
      NotificationHelper.showOrderNotification(buyerUsername, totalAmount);

      return {'success': true, 'message': 'Pembayaran berhasil!'};
    } catch (e) {
      if (errorMessage != null) {
        return {'success': false, 'message': errorMessage};
      }
      return {'success': false, 'message': 'Terjadi kesalahan saat checkout'};
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String username) async {
    return await _dbHelper.getUserTransactions(username);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    return await _dbHelper.getAllTransactions();
  }

  Future<List<Map<String, dynamic>>> getTransactionItems(int transactionId) async {
    return await _dbHelper.getTransactionItems(transactionId);
  }

  Future<double> getTotalRevenue() async {
    return await _dbHelper.getTotalRevenue();
  }
}
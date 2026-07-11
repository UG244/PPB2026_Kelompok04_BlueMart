import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  late final FirebaseFirestore _firestore;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _initialized = true;
  }

  Future<void> pushProduct(Product product) async {
    if (!_initialized) return;
    try {
      await _firestore
          .collection('products')
          .doc(product.id.toString())
          .set(product.toMap());
    } catch (_) {}
  }

  Future<void> deleteProduct(int productId) async {
    if (!_initialized) return;
    try {
      await _firestore
          .collection('products')
          .doc(productId.toString())
          .delete();
    } catch (_) {}
  }

  Future<List<Product>> pullProducts() async {
    if (!_initialized) return [];
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> pushTransaction(Map<String, dynamic> transactionData) async {
    if (!_initialized) return;
    try {
      await _firestore
          .collection('transactions')
          .doc(transactionData['id'].toString())
          .set(transactionData);
    } catch (_) {}
  }
}
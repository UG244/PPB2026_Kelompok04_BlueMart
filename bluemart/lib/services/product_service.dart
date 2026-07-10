import '../database/db_helper.dart';
import '../models/product.dart';

class ProductService {
  final DbHelper _dbHelper = DbHelper();

  Future<int> createProduct(Product product) async {
    return await _dbHelper.insertProduct(product);
  }

  Future<List<Product>> getAllProducts() async {
    return await _dbHelper.getAllProducts();
  }

  Future<List<Product>> getActiveProducts() async {
    return await _dbHelper.getActiveProducts();
  }

  Future<Product?> getProductById(int id) async {
    return await _dbHelper.getProductById(id);
  }

  Future<int> updateProduct(Product product) async {
    return await _dbHelper.updateProduct(product);
  }

  Future<int> deleteProduct(int id) async {
    return await _dbHelper.deleteProduct(id);
  }

  Future<int> getTotalProducts() async {
    return await _dbHelper.getTotalProducts();
  }

  Future<int> getTotalStock() async {
    return await _dbHelper.getTotalStock();
  }

  Future<int> getLowStockCount({int threshold = 5}) async {
    return await _dbHelper.getLowStockCount(threshold);
  }

  Future<List<Product>> getRecentProducts({int limit = 3}) async {
    return await _dbHelper.getRecentProducts(limit);
  }

  Future<void> toggleProductVisibility(int productId, bool isActive) async {
    final product = await _dbHelper.getProductById(productId);
    if (product != null) {
      await _dbHelper.updateProduct(product.copyWith(isActive: isActive));
    }
  }
}
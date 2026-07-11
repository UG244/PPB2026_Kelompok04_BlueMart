import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bluemart.db');

    return await openDatabase(
      path,
<<<<<<< Updated upstream
      version: 1,
=======
      version: 4,
>>>>>>> Stashed changes
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        initialStock INTEGER NOT NULL DEFAULT 0,
        photoPath TEXT,
        supplierId INTEGER,
        isActive INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        buyerUsername TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'completed',
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES transactions(id),
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');
<<<<<<< Updated upstream
=======

    await db.execute('''
      CREATE TABLE IF NOT EXISTS coupons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        discount TEXT NOT NULL,
        discountPercent REAL DEFAULT 0,
        minPurchase REAL NOT NULL,
        freeShipping INTEGER NOT NULL DEFAULT 0,
        expiry TEXT NOT NULL,
        uses INTEGER DEFAULT 0,
        maxUses INTEGER DEFAULT 100,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add description column if upgrading from v1
      try {
        await db.execute(
          'ALTER TABLE products ADD COLUMN description TEXT DEFAULT ""',
        );
      } catch (_) {
        // Column might already exist
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS coupons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL UNIQUE,
            discount TEXT NOT NULL,
            discountPercent REAL DEFAULT 0,
            minPurchase REAL NOT NULL,
            freeShipping INTEGER NOT NULL DEFAULT 0,
            expiry TEXT NOT NULL,
            uses INTEGER DEFAULT 0,
            maxUses INTEGER DEFAULT 100,
            isActive INTEGER NOT NULL DEFAULT 1,
            createdAt TEXT NOT NULL
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute(
          'ALTER TABLE products ADD COLUMN initialStock INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'UPDATE products SET initialStock = stock',
        );
      } catch (_) {}
    }
>>>>>>> Stashed changes
  }

  // ==================== PRODUCT CRUD ====================

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'createdAt DESC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getActiveProducts() async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTotalProducts() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return result.first['count'] as int;
  }

  Future<int> getTotalStock() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(stock), 0) as total FROM products');
    return (result.first['total'] as num).toInt();
  }

  Future<int> getLowStockCount(int threshold) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE stock < ? AND stock > 0',
      [threshold],
    );
    return result.first['count'] as int;
  }

  Future<List<Product>> getRecentProducts(int limit) async {
    final db = await database;
    final maps = await db.query(
      'products',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // ==================== TRANSACTION METHODS ====================

  Future<int> insertTransaction(Map<String, dynamic> transactionData) async {
    final db = await database;
    return await db.insert('transactions', transactionData);
  }

  Future<void> insertTransactionItem(Map<String, dynamic> itemData) async {
    final db = await database;
    await db.insert('transaction_items', itemData);
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String username) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'buyerUsername = ?',
      whereArgs: [username],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getTransactionItems(int transactionId) async {
    final db = await database;
    return await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
  }

  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(totalAmount), 0) as total FROM transactions');
    return (result.first['total'] as num).toDouble();
  }

  Future<Database> get db => database;
}
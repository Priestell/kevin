import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<void> updateOrderLivreur(int livreurId, int orderId) async {
    final db = await database;

    // Mettre à jour l'entrée dans la table des commandes pour y ajouter l'ID du livreur
    await db.update(
      'orders',
      {'user_id': livreurId},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    return await db.insert('orders', order);
  }
  Future<void> deleteOrder(int id) async {
    final db = await database;
    await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<Map<String, dynamic>> getOrderById(int id) async {
    final db = await database; // Obtenir l'instance de la base de données
    final List<Map<String, dynamic>> results = await db.query(
      'orders', // Le nom de ta table
      where: 'id = ?', // Condition pour filtrer par ID
      whereArgs: [id], // Valeur de l'ID à passer
      limit: 1, // On attend un seul résultat
    );

    if (results.isNotEmpty) {
      return results.first; // Renvoie la commande trouvée
    } else {
      throw Exception('Commande non trouvée pour l\'ID: $id'); // Lance une exception si aucune commande n'est trouvée
    }
  }
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Création des tables utilisateurs et commandes
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT UNIQUE,
        phone_number TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        price REAL,
        departure_time TEXT,
        arrival_time TEXT,
        departure_address TEXT,
        arrival_address TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // Fonctions CRUD pour les utilisateurs
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }



  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders');
  }

  Future<List<Map<String, dynamic>>> getOrdersByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

}

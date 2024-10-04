import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LivreurMapPage extends StatefulWidget {
  const LivreurMapPage({Key? key}) : super(key: key);

  @override
  _LivreurMapPageState createState() => _LivreurMapPageState();
}

class _LivreurMapPageState extends State<LivreurMapPage> {
  Database? _database;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _userId = '123'; // Remplacer par l'ID de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    _initializeDatabase();

  }

  // Ouvrir la base de données SQLite existante
  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'app_database.db'), // Chemin vers votre base de données existante
    );
    _fetchOrders(); // Récupérer les commandes après l'ouverture de la base
  }

  // Récupérer les commandes associées à l'utilisateur
  Future<void> _fetchOrders() async {
    final List<Map<String, dynamic>> orders = await _database!.query(
      'orders',
      where: 'user_id = ?', // Utiliser 'user_id' qui est défini dans la base existante
      whereArgs: [_userId],
    );

    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  // Vue pour afficher les commandes ou un message
  Widget _buildItineraryView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          'Aucune commande disponible.',
          style: TextStyle(fontSize: 24.0),
        ),
      );
    }

    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return ListTile(
          title: Text(order['title']),
          subtitle: Text('Prix: ${order['price']}€'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte Livreurs'),
      ),
      body: _buildItineraryView(), // Afficher la vue avec les commandes
    );
  }
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'commande_statut.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit(); // Initialisation sqflite_ffi pour les environnements non mobiles
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Création des tables
    await db.execute('''
    CREATE TABLE commande (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      intitule TEXT NOT NULL,
      date TEXT NOT NULL,
      description TEXT NOT NULL,
      adresse TEXT NOT NULL, -- New 'adresse' field
      statut TEXT NOT NULL,
      client_id INTEGER NOT NULL,
      prestataire_id INTEGER,
      livreur_id INTEGER,
      tarif REAL NOT NULL,
      FOREIGN KEY (client_id) REFERENCES client (id),
      FOREIGN KEY (prestataire_id) REFERENCES prestataire (id),
      FOREIGN KEY (livreur_id) REFERENCES livreur (id)
    )
  ''');
    await db.execute('''
CREATE TABLE prestataire (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL
)

    ''');
    await db.execute('''
     CREATE TABLE livreur (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  prestataire_id INTEGER, -- Define the column first
  FOREIGN KEY (prestataire_id) REFERENCES prestataire (id)
)

    ''');
  }


  Future<void> insertClient(String name, String email, String imageUrl) async {
    final db = await instance.database;

    await db.insert(
      'client',
      {'name': name, 'email': email, 'image': imageUrl},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPrestataire(String name, String service) async {
    final db = await instance.database;

    await db.insert(
      'prestataire',
      {'name': name, 'service': service},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertLivreur(String name, String vehicle) async {
    final db = await instance.database;

    await db.insert(
      'livreur',
      {'name': name, 'vehicle': vehicle},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCommandeLivreur(int commandeId, int livreurId) async {
    final db = await instance.database;
    await db.update(
      'commande',
      {'livreur_id': livreurId}, // Set the new livreur_id
      where: 'id = ?', // Find the commande by its id
      whereArgs: [commandeId],
    );
  }

  Future<List<Map<String, dynamic>>> getCommandesWithLivreurByPrestataireId(int prestataireId) async {
    final db = await instance.database;
    return await db.rawQuery('''
    SELECT commande.*, livreur.name AS livreur_name
    FROM commande
    LEFT JOIN livreur ON commande.livreur_id = livreur.id
    WHERE commande.prestataire_id = ?
  ''', [prestataireId]);
  }

  Future<bool> isLivreurAvailable(int livreurId) async {
    final db = await instance.database;
    // Check if the livreur is already assigned to any ongoing commandes
    final result = await db.query(
      'commande',
      where: 'livreur_id = ? AND statut != ?',
      whereArgs: [livreurId, 'Completed'], // Assuming 'Completed' is the status for finished commandes
    );
    return result.isEmpty; // Returns true if no ongoing commande is found
  }


  Future<void> updateCommandeLivreurAndPrestataire(int commandeId, int livreurId, int prestataireId) async {
    final db = await instance.database;
    await db.update(
      'commande',
      {
        'livreur_id': livreurId, // Set the new livreur_id
        'prestataire_id': prestataireId, // Set the prestataire_id
      },
      where: 'id = ?', // Find the commande by its id
      whereArgs: [commandeId],
    );
  }

  Future<List<Map<String, dynamic>>> getLivreursByPrestataireId(int prestataireId) async {
    final db = await instance.database;
    return await db.query(
      'livreur',
      where: 'prestataire_id = ?',
      whereArgs: [prestataireId],
    );
  }


  Future<void> insertCommande(
      String intitule,
      String date,
      String description,
      String statut,
      int clientId,
      double tarif, // Add tarif parameter
      String adresse, // Add adresse parameter
          {int? prestataireId, int? livreurId}) async {
    final db = await instance.database;

    try {
      await db.insert(
        'commande',
        {
          'intitule': intitule,
          'date': date,
          'description': description,
          'adresse': adresse, // Include adresse in the insert data
          'statut': statut,
          'client_id': clientId,
          'tarif': tarif, // Include tarif in the insert data
          'prestataire_id': prestataireId,
          'livreur_id': livreurId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Insertion failed: $e');
    }
  }





  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await instance.database;
    return await db.query('client');
  }

  Future<List<Map<String, dynamic>>> getPrestataires() async {
    final db = await instance.database;
    return await db.query('prestataire');
  }

  Future<List<Map<String, dynamic>>> getLivreurs() async {
    final db = await instance.database;
    return await db.query('livreur');
  }

  Future<List<Map<String, dynamic>>> getCommandes() async {
    final db = await instance.database;
    return await db.query('commande');
  }

  Future<void> insertCommandeStatus(
      String description,
      CommandeStatut statut, // Use the enum here
      int clientId,
      int? prestataireId,
      int? livreurId,
      ) async {
    final db = await instance.database;

    await db.insert(
      'commande',
      {
        'description': description,
        'statut': statut.value, // Convert the enum to a string
        'client_id': clientId,
        'prestataire_id': prestataireId,
        'livreur_id': livreurId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCommandesByPrestataireId(int prestataireId) async {
    final db = await instance.database;
    return await db.query(
      'commande',
      where: 'prestataire_id = ?',
      whereArgs: [prestataireId],
    );
  }

  Future<List<Map<String, dynamic>>> getCommandesWithNullPrestataire() async {
    final db = await instance.database;
    return await db.query(
      'commande',
      where: 'prestataire_id IS NULL',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<Map<String, dynamic>>> getCommandesByClientId(int clientId) async {
    final db = await instance.database;
    return await db.query(
      'commande',
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
  }
  Future<List<Map<String, dynamic>>> getCommandesByLivreurId(int clientId) async {
    final db = await instance.database;
    return await db.query(
      'commande',
      where: 'livreur_id = ?',
      whereArgs: [clientId],
    );
  }
  Future<bool> hasActiveDelivery(int livreurId) async {
    final db = await instance.database;
    final result = await db.query(
      'commande',
      where: 'livreur_id = ? AND statut != ?',
      whereArgs: [livreurId, 'Completed'], // Supposons que "Completed" signifie la fin de la livraison
    );
    return result.isNotEmpty;
  }


}

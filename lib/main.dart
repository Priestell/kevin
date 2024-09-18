// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'database/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Bar Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> _initializeDatabase() async {
    // Appel de la base de données pour s'assurer qu'elle est initialisée
    await _databaseHelper.database;
  }

  @override
  void initState() {
    super.initState();
    // Initialiser la base de données lors du démarrage de l'application
    _initializeDatabase();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shifter Pro 92'),
      ),
      body: FutureBuilder(
        future: _initializeDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
                    'Erreur lors de l\'initialisation de la base de données'));
          } else {
            return _selectedIndex == 0 ? page1() : page2();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_chart_sharp),
            label: 'Commande',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget page1() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _databaseHelper
          .getClients(), // Requête pour obtenir la liste des clients
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Erreur lors du chargement des clients'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun client trouvé'));
        } else {
          // Liste des clients récupérée
          final clients = snapshot.data!;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  leading: client['image'] != null && client['image'].isNotEmpty
                      ? Image.network(
                          client['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons
                                .error); // Icône d'erreur si l'image ne se charge pas
                          },
                        )
                      : const Icon(
                          Icons.person), // Icône par défaut si pas d'image
                  title: Text(client['name']),
                  subtitle: Text(client['email']),
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future:
                          _databaseHelper.getCommandesByClientId(client['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text(
                                  'Erreur lors du chargement des commandes'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Aucune commande pour ce client'),
                          );
                        } else {
                          final commandes = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: commandes.length,
                            itemBuilder: (context, index) {
                              final commande = commandes[index];
                              return ListTile(
                                title: Text('Commande ${commande['id']}'),
                                subtitle: Text(commande['description']),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget page2() {
    return const Center(child: Text("Salut"),);
  }
}



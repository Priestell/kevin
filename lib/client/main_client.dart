// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shifterpro/client/commande_form.dart';
import '../database/database.dart';
import 'commande_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShifterPro',
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
    return const CommandesList();
  }

  Widget page2()
  {
    return const CommandeForm();
  }
}


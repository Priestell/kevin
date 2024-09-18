// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../database/database.dart';

class CommandesList extends StatefulWidget {
  const CommandesList({super.key});

  @override
  _CommandesListState createState() => _CommandesListState();
}

class _CommandesListState extends State<CommandesList> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseHelper.getCommandesByClientId(1), // Fetch commands for clientId = 1
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement des commandes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune commande pour l\'instant !'));
          } else {
            // List of commands retrieved
            final commandes = snapshot.data!;

            return ListView.builder(
              itemCount: commandes.length,
              itemBuilder: (context, index) {
                final commande = commandes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('${commande['intitule']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${commande['date']}'),
                        Text('Description: ${commande['description']}'),
                        Text('Tarif: ${commande['tarif'] ?? 'N/A'}'),
                        Text('Statut: ${commande['statut']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

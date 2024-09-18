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
      appBar: AppBar(
        title: const Text('Liste des Commandes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseHelper.getCommandesWithLivreurByPrestataireId(1), // Fetch commands for prestataireId = 1
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
                        // Display the name of the livreur
                        Text('Livreur: ${commande['livreur_name'] ?? 'Aucun'}'),
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

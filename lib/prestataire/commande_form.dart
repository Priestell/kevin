import 'package:flutter/material.dart';
import '../database/database.dart';

class CommandesSansPrestataireList extends StatefulWidget {
  const CommandesSansPrestataireList({super.key});

  @override
  _CommandesSansPrestataireListState createState() => _CommandesSansPrestataireListState();
}

class _CommandesSansPrestataireListState extends State<CommandesSansPrestataireList> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Method to show a confirmation dialog
  void _showConfirmationDialog(BuildContext context, Map<String, dynamic> commande) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir effectuer cette action?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Perform the action here, e.g., assign a livreur
                _performAction(commande);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // Method to perform the action and show a dialog to assign a livreur
  void _performAction(Map<String, dynamic> commande) async {
    // Fetch livreurs with prestataire_id = 1
    List<Map<String, dynamic>> livreurs = await _databaseHelper.getLivreursByPrestataireId(1);

    // Show dialog with the list of livreurs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assigner un livreur'),
          content: livreurs.isNotEmpty
              ? SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: livreurs.length,
              itemBuilder: (context, index) {
                final livreur = livreurs[index];
                return ListTile(
                  title: Text('${livreur['name']}'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Assign the selected livreur to the commande
                    _assignLivreurToCommande(commande, livreur);
                  },
                );
              },
            ),
          )
              : const Text('Aucun livreur disponible'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  // Dummy method to assign a livreur to a commande
  // Method to assign a livreur to a commande
// Method to assign a livreur and prestataire to a commande
// Method to assign a livreur and prestataire to a commande
  void _assignLivreurToCommande(Map<String, dynamic> commande, Map<String, dynamic> livreur) async {
    try {
      // Check if the livreur is available
      bool isAvailable = await _databaseHelper.isLivreurAvailable(livreur['id']);

      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le livreur ${livreur['name']} est déjà assigné à une autre commande')),
        );
        return;
      }

      // Update the commande with the selected livreur_id and prestataire_id
      await _databaseHelper.updateCommandeLivreurAndPrestataire(
        commande['id'],
        livreur['id'],
        livreur['prestataire_id'], // Use the prestataire_id from the selected livreur
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Livreur ${livreur['name']} assigné à la commande: ${commande['intitule']}')),
      );

      // Refresh the UI to reflect the changes
      setState(() {});
    } catch (e) {
      // Handle any errors during the update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'assignation du livreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes sans prestataire'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseHelper.getCommandesWithNullPrestataire(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement des commandes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune commande sans prestataire pour l\'instant !'));
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
                        Text('Adresse: ${commande['adresse'] ?? 'N/A'}'), // Display the address
                        Text('Tarif: ${commande['tarif'] ?? 'N/A'}'),
                        Text('Statut: ${commande['statut']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_add),
                      onPressed: () {
                        _showConfirmationDialog(context, commande);
                      },
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

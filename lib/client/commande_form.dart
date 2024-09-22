import 'package:flutter/material.dart';
import '../database/database.dart';

class CommandeForm extends StatefulWidget {
  const CommandeForm({super.key});

  @override
  _CommandeFormState createState() => _CommandeFormState();
}

class _CommandeFormState extends State<CommandeForm> {
  // Controllers to capture user input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _adresseDepartController = TextEditingController();
  final TextEditingController _horaireDepartController = TextEditingController();
  final TextEditingController _adresseLivraisonController = TextEditingController();
  final TextEditingController _horaireLivraisonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _tarifController = TextEditingController();

  // Database helper instance
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Method to handle form submission
  Future<void> _addCommande() async {
    // Get input values
    String title = _titleController.text;
    String adresseDepart = _adresseDepartController.text;
    String horaireDepart = _horaireDepartController.text;
    String adresseLivraison = _adresseLivraisonController.text;
    String horaireLivraison = _horaireLivraisonController.text;
    String description = _descriptionController.text;
    String contact = _contactController.text;
    String tarif = _tarifController.text;

    // Validate input
    if (title.isEmpty || adresseDepart.isEmpty || horaireDepart.isEmpty || adresseLivraison.isEmpty || horaireLivraison.isEmpty || contact.isEmpty || tarif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    // Convert tarif to a double
    double tarifValue;
    try {
      tarifValue = double.parse(tarif);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le tarif doit être un nombre valide')),
      );
      return;
    }

    try {
      await _databaseHelper.insertCommande(
        title, // 'intitule' field// Empty string for date, since it's removed
        description, // 'description' field
        'A pourvoir', // 'statut' field - default status
        1, // 'clientId' - use a valid client ID here
        tarifValue, // Pass the tarif value as double
        adresseDepart,
        horaireDepart,
        adresseLivraison,
        horaireLivraison,
        description,
        contact,
        prestataireId: null,
        livreurId: null,
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande ajoutée avec succès')),
      );

      // Clear the form fields
      _titleController.clear();
      _adresseDepartController.clear();
      _horaireDepartController.clear();
      _adresseLivraisonController.clear();
      _horaireLivraisonController.clear();
      _descriptionController.clear();
      _contactController.clear();
      _tarifController.clear();
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de la commande: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Adding some padding around the list
        children: [
          // Command Title
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3), // Lighter shadow color
                  spreadRadius: 1, // Reduced spread
                  blurRadius: 4, // Softer blur
                  offset: const Offset(0, 2), // Slightly lower offset
                ),
              ],
            ),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Intitulé de la commande',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // 2x2 Grid for Address and Time
          Row(
            children: [
              // First Column
              Flexible(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _adresseDepartController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse de départ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _horaireDepartController,
                        decoration: const InputDecoration(
                          labelText: 'Horaire de départ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0), // Space between columns

              // Second Column
              Flexible(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _adresseLivraisonController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse de livraison',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _horaireLivraisonController,
                        decoration: const InputDecoration(
                          labelText: 'Horaire souhaité pour la livraison',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Description
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 4, // Set to more lines for a longer input
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // 1x1 Grid for Contact and Tarif
          Row(
            children: [
              // Contact
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // Space between contact and tarif

              // Tarif
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _tarifController,
                    decoration: const InputDecoration(
                      labelText: 'Tarif',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // Numeric input
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Submit Button
          SizedBox(
            width: double.infinity, // Full width button
            child: ElevatedButton(
              onPressed: _addCommande, // Call the method to add the command
              child: const Text('Valider'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controllers when the form is disposed
    _titleController.dispose();
    _adresseDepartController.dispose();
    _horaireDepartController.dispose();
    _adresseLivraisonController.dispose();
    _horaireLivraisonController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _tarifController.dispose();
    super.dispose();
  }
}

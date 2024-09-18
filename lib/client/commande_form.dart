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
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tarifController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();



  // Database helper instance
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Method to handle form submission
  Future<void> _addCommande() async {
    // Get input values
    String title = _titleController.text;
    String date = _dateController.text;
    String description = _descriptionController.text;
    String tarif = _tarifController.text;
    String adresse = _adresseController.text;

    // Validate input
    if (title.isEmpty || date.isEmpty || description.isEmpty || tarif.isEmpty || adresse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
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
        title, // 'intitule' field
        date,  // 'date' field
        description, // 'description' field
        'A pourvoir', // 'statut' field - default status
        1, // 'clientId' - use a valid client ID here
        tarifValue, // Pass the tarif value as double
        adresse, // Pass the address as a positional argument
        // Optional fields: provide null or actual values if you have them
        prestataireId: null,
        livreurId: null,
      );


      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande ajoutée avec succès')),
      );

      // Clear the form fields
      _titleController.clear();
      _dateController.clear();
      _descriptionController.clear();
      _tarifController.clear();
      _adresseController.clear();
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
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Intitulé de la commande',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),

          // Date and Time on the same line
          Row(
            children: [
              // Date
              Flexible(
                child: TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // Spacing between date and time fields

              // Time
              Flexible(
                child: TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Heure',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Description
          TextField(
            controller: _descriptionController,
            maxLines: 4, // Set to more lines for a longer input
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),

          // Tarif
          TextField(
            controller: _tarifController,
            decoration: const InputDecoration(
              labelText: 'Tarif',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number, // Numeric input
          ),
          const SizedBox(height: 24.0),

          TextField(
            controller: _adresseController,
            decoration: const InputDecoration(
              labelText: 'Adresse de livraison',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24.0,),
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
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _tarifController.dispose();
    _adresseController.dispose();
    super.dispose();
  }
}

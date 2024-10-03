import 'package:flutter/material.dart';
import 'package:kevin/DatabaseHelper.dart';

class CreateCommande extends StatefulWidget {
  final int? orderId; // Accepte l'ID de la commande à modifier

  const CreateCommande({super.key, this.orderId});

  @override
  _CreateCommandeState createState() => _CreateCommandeState();
}

class _CreateCommandeState extends State<CreateCommande> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de saisie
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _departureAddressController = TextEditingController();
  final TextEditingController _arrivalAddressController = TextEditingController();
  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;

  @override
  void initState() {
    super.initState();
    // Si un orderId est passé, charger les données de la commande existante
    if (widget.orderId != null) {
      _loadOrderData(widget.orderId!);
    }
  }

  Future<void> _loadOrderData(int orderId) async {
    // Charge les données de la commande depuis la base de données
    final order = await DatabaseHelper().getOrderById(orderId);
    setState(() {
      _titleController.text = order['title'];
      _priceController.text = order['price'].toString();
      _departureAddressController.text = order['departure_address'];
      _arrivalAddressController.text = order['arrival_address'];
      // Convertir l'heure stockée en TimeOfDay
      _departureTime = _stringToTimeOfDay(order['departure_time']);
      _arrivalTime = _stringToTimeOfDay(order['arrival_time']);
    });
  }

  // Fonction pour convertir une chaîne "HH:mm" en TimeOfDay
  TimeOfDay _stringToTimeOfDay(String time) {
    // Remplacer 'h' par ':' si nécessaire pour gérer les formats comme '14h00'
    time = time.replaceAll('h', ':');

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId == null
            ? 'Créer une Commande'
            : 'Modifier la Commande'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(
            minWidth: 300, // Taille minimum
            maxWidth: 600, // Taille maximum
          ),
          decoration: BoxDecoration(
            color: Colors.white, // Couleur de fond
            borderRadius: BorderRadius.circular(10.0), // Bordure arrondie
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Ombre
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // Position de l'ombre
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un prix valide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _departureAddressController,
                  decoration: const InputDecoration(labelText: 'Adresse de départ'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une adresse de départ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _arrivalAddressController,
                  decoration: const InputDecoration(labelText: 'Adresse d\'arrivée'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une adresse d\'arrivée';
                    }
                    return null;
                  },
                ),
                // Sélectionner l'heure de départ
                ListTile(
                  title: const Text('Heure de départ'),
                  subtitle: _departureTime == null
                      ? const Text('Aucune heure sélectionnée')
                      : Text(_departureTime!.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: _departureTime ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _departureTime = selectedTime;
                      });
                    }
                  },
                ),
                // Sélectionner l'heure d'arrivée
                ListTile(
                  title: const Text('Heure d\'arrivée'),
                  subtitle: _arrivalTime == null
                      ? const Text('Aucune heure sélectionnée')
                      : Text(_arrivalTime!.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: _arrivalTime ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _arrivalTime = selectedTime;
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Code pour créer ou modifier la commande
                  },
                  child: Text(widget.orderId == null ? 'Créer' : 'Modifier'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

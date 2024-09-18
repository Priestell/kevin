import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../database/database.dart'; // Importer DatabaseHelper

class MapExampleWithCommandInfo extends StatefulWidget {
  @override
  _MapExampleWithCommandInfoState createState() => _MapExampleWithCommandInfoState();
}

class _MapExampleWithCommandInfoState extends State<MapExampleWithCommandInfo> {
  // Coordonnées de départ (par exemple, la position simulée du livreur)
  final LatLng _currentPosition = LatLng(48.8566, 2.3522); // Paris

  // Coordonnées de destination (à récupérer à partir de la commande)
  LatLng _destination = LatLng(48.864716, 2.349014); // Valeur par défaut

  // Liste des points de l'itinéraire
  List<LatLng> _routePoints = [];

  // Informations de la commande (à récupérer à partir de la base de données)
  String _commandeTitle = '';
  String _commandeAddress = '';
  String _commandeDescription = '';

  @override
  void initState() {
    super.initState();
    // Récupérer les informations de la commande attribuée au livreur
    _fetchCommandeInfo();
  }

  // Méthode pour récupérer les informations de la commande assignée au livreur avec `livreur_id = 1`
  Future<void> _fetchCommandeInfo() async {
    final dbHelper = DatabaseHelper.instance;

    try {
      // Récupérer les commandes avec `livreur_id = 1`
      List<Map<String, dynamic>> commandes = await dbHelper.getCommandesByLivreurId(1);

      if (commandes.isNotEmpty) {
        final commande = commandes.first;

        // Mettre à jour les détails de la commande
        setState(() {
          _commandeTitle = commande['intitule'] ?? '';
          _commandeAddress = commande['adresse'] ?? '';
          _commandeDescription = commande['description'] ?? '';
        });

        // Géocoder l'adresse si latitude et longitude sont nulles
        if (commande['latitude'] == null || commande['longitude'] == null) {
          await _geocodeAddress(_commandeAddress);
        } else {
          // Utiliser les coordonnées existantes
          setState(() {
            _destination = LatLng(commande['latitude'], commande['longitude']);
          });
        }

        // Appeler l'API de routage pour obtenir l'itinéraire
        _fetchRoute();
      } else {
        print('Aucune commande trouvée pour ce livreur.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations de la commande: $e');
    }
  }

  // Méthode pour géocoder l'adresse en utilisant Mapbox
  Future<void> _geocodeAddress(String address) async {
    const apiKey = 'pk.eyJ1IjoicHJpZXN0ZWxsIiwiYSI6ImNtMGpsYmd5ZTB4cHYya3NnbWhudmsxdm0ifQ.qAIA-lMhh4ClRI7wIB1aPQ'; // Remplacez par votre clé API Mapbox
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(address)}.json?access_token=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final geometry = data['features'][0]['geometry'];
          final double lat = geometry['coordinates'][1];
          final double lon = geometry['coordinates'][0];

          setState(() {
            _destination = LatLng(lat, lon);
          });
        } else {
          print('Aucune coordonnée trouvée pour cette adresse.');
        }
      } else {
        print('Erreur lors du géocodage de l\'adresse: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  // Méthode pour récupérer l'itinéraire et les instructions à partir de l'API Mapbox
  Future<void> _fetchRoute() async {
    const apiKey = 'pk.eyJ1IjoicHJpZXN0ZWxsIiwiYSI6ImNtMGpsYmd5ZTB4cHYya3NnbWhudmsxdm0ifQ.qAIA-lMhh4ClRI7wIB1aPQ'; // Remplacez par votre clé API Mapbox
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/${_currentPosition.longitude},${_currentPosition.latitude};${_destination.longitude},${_destination.latitude}?geometries=geojson&access_token=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

        // Convertir les coordonnées en une liste de LatLng
        setState(() {
          _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      } else {
        print('Erreur lors de la récupération de l\'itinéraire: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte avec Itinéraire'),
      ),
      body: Column(
        children: [
          // Carte centrée en haut
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Utiliser 40% de la hauteur de l'écran
            child: FlutterMap(
              options: MapOptions(
                center: _currentPosition, // Centrer la carte sur la position simulée
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.yourapp',
                ),
                // Marqueur pour la position simulée (livreur)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition,
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    // Marqueur pour la destination (adresse de la commande)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _destination,
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                // Afficher l'itinéraire sur la carte
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Informations sur la commande en dessous de la carte
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _commandeTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adresse : $_commandeAddress',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description : $_commandeDescription',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kevin/admin/dashboard_admin.dart';

class CreateLivreurPage extends StatefulWidget {
  const CreateLivreurPage({super.key});

  @override
  _CreateLivreurPageState createState() => _CreateLivreurPageState();
}

class _CreateLivreurPageState extends State<CreateLivreurPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  // Fonction pour inscrire un nouveau livreur
  Future<void> signUpLivreur() async {
    setState(() {
      _isLoading = true;
    });
    try {
      SignUpResult result = await Amplify.Auth.signUp(
        username: _emailController.text,
        password: _passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: _emailController.text,
            CognitoUserAttributeKey.givenName: _firstNameController.text,
            CognitoUserAttributeKey.familyName: _lastNameController.text,
          },
        ),
      );

      // Appeler immédiatement l'API pour ajouter l'utilisateur au groupe "livreur"
      await addUserToGroup(_emailController.text);

      // Si l'inscription est en attente de confirmation, on considère cela comme un succès
      if (!result.isSignUpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès - Confirmation en attente.')),
        );

        // Réinitialiser les champs du formulaire
        _emailController.clear();
        _passwordController.clear();
        _firstNameController.clear();
        _lastNameController.clear();

        // Rediriger vers la page principale en utilisant le widget directement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard_Livreur()), // Remplace MainPage par le widget de la page principale
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte livreur créé avec succès')),
        );
      }
    } on AuthException catch (e) {
      safePrint('Erreur lors de la création du compte livreur: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addUserToGroup(String username) async {
    try {
      String apiUrl = 'https://ljgutu0567.execute-api.eu-west-3.amazonaws.com/dev/comptelivreur';
      var body = jsonEncode({
        'userName': username,
        'userPoolId': "eu-west-3_aAqp0e3T9"
      });

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      // Gérer les erreurs ici
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte livreur'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(
            minWidth: 300, // Taille minimum
            maxWidth: 600, // Taille maximum
          ),
          decoration: BoxDecoration(
            color: Colors.white, // Couleur de fond du formulaire
            borderRadius: BorderRadius.circular(10.0), // Bordures arrondies
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Ombre légère
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // Position de l'ombre
              ),
            ],
          ),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: signUpLivreur,
                  child: const Text('Créer le compte livreur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}

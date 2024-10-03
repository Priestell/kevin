import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kevin/DatabaseHelper.dart';
import 'package:kevin/admin/creation_livreur.dart';
import 'package:kevin/admin/creation_commande.dart';

Future<void> signOutCurrentUser() async {
  final result = await Amplify.Auth.signOut();
  if (result is CognitoCompleteSignOut) {
    safePrint('Sign out completed successfully');
  } else if (result is CognitoFailedSignOut) {
    safePrint('Error signing user out: ${result.exception.message}');
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = 0.0;
      const end = 1.0;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
  );
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> orders = [];
  Map<int, bool> _isHovering = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final dbHelper = DatabaseHelper();

    // Récupérer les utilisateurs et commandes
    List<Map<String, dynamic>> userResults = await dbHelper.getUsers();
    List<Map<String, dynamic>> orderResults = await dbHelper.getOrders();

    setState(() {
      users = userResults;
      orders = orderResults;
      _isHovering = {for (var user in users) user['id']: false};
    });
  }

  Future<void> _associateOrderWithLivreur(int livreurId, int orderId) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateOrderLivreur(livreurId, orderId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commande associée avec succès')),
    );

    _fetchData(); // Recharger les données après association
  }

  void _showOrderDialog(BuildContext context, Map<String, dynamic> user) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return AlertDialog(
          title: Text('Associer une commande à ${user['first_name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: orders.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order['title']),
                  subtitle: Text('Prix: ${order['price']}'),
                  onTap: () {
                    _associateOrderWithLivreur(user['id'], order['id']);
                    Navigator.of(context).pop();
                  },
                );
              },
            )
                : const Text('Aucune commande disponible.'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation1,
          curve: Curves.easeInOut,
        );
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                'Menu Administration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Créer un compte livreur'),
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: const CreateLivreurPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Créer une commande'),
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: const CreateCommande()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                signOutCurrentUser();
              },
            ),
          ],
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: orders.isNotEmpty
                ? ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order['title']),
                  subtitle: Text(
                      'Prix: ${order['price']} - Départ: ${order['departure_time']} - Arrivée: ${order['arrival_time']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateCommande(
                                orderId: order['id'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final bool confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    'Supprimer la commande'),
                                content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer cette commande ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context)
                                            .pop(false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context)
                                            .pop(true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                              false;

                          if (confirm) {
                            await DatabaseHelper()
                                .deleteOrder(order['id']);
                            setState(() {
                              orders.removeAt(index);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Commande supprimée')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            )
                : const Center(
              child: Text(
                'Aucune commande disponible.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: users.isNotEmpty
                        ? ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        // Déterminer si l'utilisateur est déjà affecté à une commande
                        bool hasOrder = orders.any((order) => order['user_id'] == user['id']);
                        String tooltipMessage = hasOrder
                            ? 'Livreur déjà affecté à une commande'
                            : 'Aucune commande assignée';

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _isHovering[user['id']] = true;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _isHovering[user['id']] = false;
                            });
                          },
                          child: Tooltip(
                            message: tooltipMessage, // Le message du tooltip
                            child: Container(
                              color: _isHovering[user['id']]!
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.transparent, // Change la couleur au survol
                              child: ListTile(
                                title: Text('${user['first_name']} ${user['last_name']}'),
                                subtitle: Text(user['email']),
                                onTap: () {
                                  // Ouvre une boîte de dialogue pour associer une commande à ce livreur
                                  _showOrderDialog(context, user);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Text(
                        'Aucun utilisateur disponible.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

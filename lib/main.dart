import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kevin/livreur/dashboard_livreur.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'admin/dashboard_admin.dart';
import 'amplify_outputs.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    var path = 'my_web_web.db';// Enregistrer l'implémentation web
  }

}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

Future<void> signOutCurrentUser() async {
  final result = await Amplify.Auth.signOut();
  if (result is CognitoCompleteSignOut) {
    safePrint('Sign out completed successfully');
  } else if (result is CognitoFailedSignOut) {
    safePrint('Error signing user out: ${result.exception.message}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: const HomePage(),
      ),
    );
  }
}

// HomePage avec StatefulWidget pour gérer la navigation automatique après connexion
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationStatus();
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    // Vérifie si l'utilisateur est connecté et redirige automatiquement
    bool isSignedIn = await Amplify.Auth.fetchAuthSession().then((session) => session.isSignedIn);
    if (isSignedIn) {
      await fetchCognitoAuthSession(context);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> decodeAccessToken(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('value') && jsonData['value'].containsKey('accessToken')) {
      String accessToken = jsonData['value']['accessToken'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      List<dynamic> userGroups = decodedToken['cognito:groups'];
      return userGroups;
    } else {
      return [];
    }
  }

  Future<void> fetchCognitoAuthSession(BuildContext context) async {
    try {
      final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();
      var test = result.userPoolTokensResult.toJson();

      List<dynamic> userGroups = decodeAccessToken(test);

      if (userGroups.contains('livreur')) {
        _navigateWithFade(context, const LivreurMapPage());
      } else if (userGroups.contains('admin')) {
        _navigateWithFade(context, const Dashboard_Livreur());
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateWithFade(BuildContext context, Widget page) {
    _controller!.forward();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child,) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()  // Affichage d'attente
            else
              const Text("Erreur lors de la récupération des informations."),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}



// Page pour les admins


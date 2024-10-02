import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'amplify_outputs.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
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


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Appelle fetchCognitoAuthSession dès que l'utilisateur est authentifié
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationStatus();
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    // Vérifie si l'utilisateur est connecté et redirige automatiquement
    bool isSignedIn = await Amplify.Auth.fetchAuthSession().then((session) => session.isSignedIn);
    if (isSignedIn) {
      fetchCognitoAuthSession(context);
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LivreurPage()),
        );
      } else if (userGroups.contains('admin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
      }
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          ],
        ),
      ),
    );
  }
}


class LivreurPage extends StatelessWidget {
  const LivreurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Livreur')),
      body: const Center(
        child: Text('Bienvenue sur la page Livreur!'),
      ),
    );
  }
}


class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Admin')),
      body: const Center(
        child: Text('Bienvenue sur la page Admin!'),
      ),
    );
  }
}

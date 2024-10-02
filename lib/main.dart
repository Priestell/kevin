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

Future<void> _fetchAuthSession() async {
  final authSession = await Amplify.Auth.fetchAuthSession();
  print(authSession);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home:  Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SignOutButton(),
                const Text('TODO Application'),
                ElevatedButton(onPressed: () {fetchCognitoAuthSession();}, child: const Text("Salut"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<dynamic> decodeAccessToken(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('value') && jsonData['value'].containsKey('accessToken')) {
      String accessToken = jsonData['value']['accessToken'];
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      List<dynamic> userId = decodedToken['cognito:groups'];
      return userId;
    } else {
      print('AccessToken non trouvé dans le JSON.');
      return [{}];
    }
  }
  Future<void> fetchCognitoAuthSession() async {
    try {
      final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();
      var test = result.userPoolTokensResult.toJson();

      print(decodeAccessToken(test));
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
    } catch (e) {
      print('Erreur inattendue: $e');
    }
  }

}
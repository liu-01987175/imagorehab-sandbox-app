import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _userPoolId = 'us-east-2_zFctSxiQQ';
  static const String _clientId = '3mban00v1q1g1ug2g00nml6d91';

  final CognitoUserPool _userPool = CognitoUserPool(_userPoolId, _clientId);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Signs in a user with AWS Cognito, ensuring non-null session and token.
  Future<bool> signIn(String email, String password) async {
    final user = CognitoUser(email, _userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );
    try {
      final session = await user.authenticateUser(authDetails);
      if (session == null) {
        print('❌ Cognito authenticateUser returned null');
        return false;
      }
      if (!session.isValid()) {
        print('❌ Session is not valid');
        return false;
      }

      final idTokenObj = session.getIdToken();
      if (idTokenObj == null) {
        print('❌ Unable to retrieve ID token');
        return false;
      }

      final jwt = idTokenObj.getJwtToken();
      print('✅ ID token: $jwt');
      await _storage.write(key: 'idToken', value: jwt);
      return true;
    } on CognitoClientException catch (e) {
      print('❌ Cognito error [${e.code}]: ${e.message}');
    } catch (e) {
      print('❌ Unknown signIn error: $e');
    }
    return false;
  }

  /// Registers a new user in AWS Cognito
  Future<bool> signUp(String email, String password) async {
    try {
      final result = await _userPool.signUp(
        email,
        password,
        userAttributes: [AttributeArg(name: 'email', value: email)],
      );
      print('✅ signUp result: confirmed=${result.userConfirmed}');
      return result.userConfirmed ?? false;
    } on CognitoClientException catch (e) {
      print('❌ Cognito signUp error [${e.code}]: ${e.message}');
    } catch (e) {
      print('❌ Unknown signUp error: $e');
    }
    return false;
  }

  /// Clears the locally stored ID token.
  Future<void> signOut() async {
    await _storage.delete(key: 'idToken');
    print('🔐 User signed out (token cleared)');
  }
}

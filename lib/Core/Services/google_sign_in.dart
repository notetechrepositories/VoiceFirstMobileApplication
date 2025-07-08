import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId:
      '679962409410-rj73epta3a621j7eus1cm0i47rse9g7v.apps.googleusercontent.com',
);

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  String? _error;

  Future<void> _handleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      final auth = await account?.authentication;

      if (auth?.idToken != null) {
        final payload = _decodeJWT(auth!.idToken!);
        print('Decoded Payload: $payload');

        // Now send to your backend to check user existence
        final email = payload['email'];
        final isVerified = payload['email_verified'];

        if (isVerified) {
          final res = await http.get(
            Uri.parse('http://YOUR_API/user-exists?email=$email'),
          );

          final resBody = jsonDecode(res.body);

          if (resBody['exists'] == true) {
            // Navigate to home
            Navigator.pushNamed(context, '/home');
          } else {
            // Navigate to registration
            Navigator.pushNamed(context, '/register', arguments: payload);
          }
        }
      }
    } catch (e) {
      setState(() => _error = 'Google Sign-In failed: $e');
    }
  }

  Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('invalid token');
    final payload = parts[1];

    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return json.decode(decoded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign-In')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}

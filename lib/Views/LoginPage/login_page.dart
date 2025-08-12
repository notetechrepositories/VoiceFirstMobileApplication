import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Views/CompanySide/CompanyHome/company_home.dart';
import 'package:voicefirst/Views/Dashboard/bottom_bar.dart';
import 'package:voicefirst/Views/Registration/user_register_page1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Secure storage keys
  static const _kUserTokenKey = 'user_access_token';
  static const _kCompanyTokenKey = 'company_access_token';
  static const _kActiveTokenKey = 'active_access_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _saveTokens({String? userToken, String? companyToken}) async {
    // Clear old tokens first (prevents stale values)
    await _secureStorage.delete(key: _kUserTokenKey);
    await _secureStorage.delete(key: _kCompanyTokenKey);
    await _secureStorage.delete(key: _kActiveTokenKey);

    if (userToken != null && userToken.isNotEmpty) {
      await _secureStorage.write(key: _kUserTokenKey, value: userToken);
    }
    if (companyToken != null && companyToken.isNotEmpty) {
      await _secureStorage.write(key: _kCompanyTokenKey, value: companyToken);
    }
  }

  Future<void> _setActiveToken(String token) async {
    await _secureStorage.write(key: _kActiveTokenKey, value: token);
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final url = Uri.parse('${ApiEndpoints.baseUrl}/Auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final responseBody = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && responseBody['isSuccess'] == true) {
        final data = responseBody['data'] ?? {};
        final String? userAccessToken = data['userAccessToken'];
        final String? companyAccessToken = data['companyAccessToken'];

        // Save both tokens if present
        await _saveTokens(
          userToken: userAccessToken,
          companyToken: companyAccessToken,
        );

        // Route & set active token based on what we received
        if (userAccessToken != null && companyAccessToken != null) {
          _showRoleChoiceDialog(
            onUser: () async {
              await _setActiveToken(userAccessToken);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Bottomnavbar()),
              );
            },
            onCompany: () async {
              await _setActiveToken(companyAccessToken);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CompanyHome()),
              );
            },
          );
        } else if (userAccessToken != null) {
          await _setActiveToken(userAccessToken);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Bottomnavbar()),
          );
        } else if (companyAccessToken != null) {
          await _setActiveToken(companyAccessToken);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyHome()),
          );
        } else {
          setState(() {
            _errorMessage = 'No valid access token returned.';
          });
        }
      } else {
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _showRoleChoiceDialog({
    required Future<void> Function() onUser,
    required Future<void> Function() onCompany,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Role'),
        content: const Text('You can continue as User or Company.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onUser();
            },
            child: const Text('User'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onCompany();
            },
            child: const Text('Company'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 245, 198, 57),
              Color.fromARGB(255, 252, 237, 155),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Hello',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Login Account',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Enter your credentials below.',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_errorMessage.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        _errorMessage,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text('Save Password'),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    child: InkWell(
                                      onTap: _isLoading ? null : _login,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 17, 17, 17),
                                              Color.fromARGB(255, 56, 56, 55),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: _isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                'Login Account',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Don\'t have an account? Register Here',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
import 'package:voicefirst/Views/CompanySide/CompanyIssueStatus/company_issue_status.dart';
import 'package:voicefirst/Views/Dashboard/bottom_bar.dart';
import 'package:voicefirst/Views/CompanySide/CompanyHome/company_home.dart';
import 'package:voicefirst/Views/Registration/user_register_page1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  final Dio _dio = ApiClient().dio;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _setActiveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await _secureStorage.write(key: 'active_access_token', value: token);
  }

  Future<void> _saveAllTokens({String? userToken, String? companyToken}) async {
    if (userToken != null && userToken.isNotEmpty) {
      await _secureStorage.write(key: 'user_access_token', value: userToken);
    }
    if (companyToken != null && companyToken.isNotEmpty) {
      await _secureStorage.write(
        key: 'company_access_token',
        value: companyToken,
      );
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final res = await _dio.post(
        '/Auth/login',
        // Let Dio JSON-encode a Map; no need to jsonEncode.
        data: {'username': username, 'password': password},
      );

      setState(() => _isLoading = false);

      final body = res.data is Map ? res.data as Map : jsonDecode(res.data);
      if (body['isSuccess'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final String? userToken = data['userAccessToken'] as String?;
        final String? companyToken = data['companyAccessToken'] as String?;

        // Save both tokens
        await _saveAllTokens(userToken: userToken, companyToken: companyToken);

        // Default the active token to COMPANY to avoid 401 on company-scoped pages prefetching data.
        // The role picker below will override this if the user chooses "User".
        if ((companyToken?.isNotEmpty ?? false)) {
          await _setActiveToken(companyToken);
        } else if ((userToken?.isNotEmpty ?? false)) {
          await _setActiveToken(userToken);
        }

        // Route logic
        if ((userToken?.isNotEmpty ?? false) &&
            (companyToken?.isNotEmpty ?? false)) {
          _showRolePicker(userToken: userToken!, companyToken: companyToken!);
        } else if (userToken != null && userToken.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Bottomnavbar()),
          );
        } else if (companyToken != null && companyToken.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyHome()),
          );
        } else {
          setState(() => _errorMessage = 'No valid role/token returned.');
        }
      } else {
        setState(() {
          _errorMessage = (body['message'] ?? 'Login failed').toString();
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.response?.data is Map
            ? ((e.response!.data['message'])?.toString() ?? 'Login failed')
            : 'Login failed';
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _showRolePicker({
    required String userToken,
    required String companyToken,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Role'),
        content: const Text(
          'You have access to both User and Company. Choose one to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Switch active token to USER when they pick User
              await _setActiveToken(userToken);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Bottomnavbar()),
              );
            },
            child: const Text('User'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Switch active token to COMPANY when they pick Company
              await _setActiveToken(companyToken);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CompanyHome()),
              );
            },
            child: const Text('Company'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5C639), Color(0xFFFCEB9B)],
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
                        SizedBox(height: screenH * 0.08),
                        Column(
                          children: [
                            Text(
                              'Hello',
                              style: TextStyle(
                                fontSize: screenW * 0.12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: screenW * 0.05,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenH * 0.05),
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
                                        onPressed: () => setState(
                                          () => _isPasswordVisible =
                                              !_isPasswordVisible,
                                        ),
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
                                              Color(0xFF111111),
                                              Color(0xFF383837),
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
                                fontSize: screenW * 0.045,
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

import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Registration/preview_page.dart';
import 'package:voicefirst/Views/Registration/user_register_page2.dart';
import 'package:voicefirst/Widgets/bread_crumb.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';
import 'package:voicefirst/Widgets/registerform.dart';
// import 'package:voicefirst/Views/RegistrationPage/registration_page.dart';

class PasswordPage extends StatefulWidget {
  // const PasswordPage({Key? key}) : super(key: key);

  final RegistrationData registrationData;

  PasswordPage({required this.registrationData});

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Register function

  Future<bool> registerUser(RegistrationData data) async {
    final url = Uri.parse('http://your-api-endpoint/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 200) {
          // Registration successful
          return true;
        } else {
          // Handle server error
          print(responseBody['message']);
          return false;
        }
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordController.text = widget.registrationData.password;
    _confirmPasswordController.text = widget.registrationData.confirmPassword;
  }

  //   final success = await registerUser(registrationData);
  // if (success) {
  //   // Navigate or show success
  //   Navigator.pushReplacementNamed(context, '/login');
  // } else {
  //   // Show error
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Registration failed')),
  //   );
  // }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 246, 202, 71),
              Color.fromARGB(255, 246, 208, 97),
              Color.fromARGB(255, 252, 238, 158),
              Color.fromARGB(255, 241, 235, 204),
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
                        // SizedBox(height: screenHeight * 0.02),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
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
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Register Account',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Enter your Details below.',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 20),
                                  
                                  StepBreadcrumb(
                                    currentStep: 2,
                                    steps: [
                                      'Basic',
                                      'Address',
                                      'Password',
                                      'Confirm',
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  // Password Field
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    
                                    decoration: buildInputDecoration(
                                      'Password',
                                      const Icon(Icons.lock),
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
                                  SizedBox(height: 15),

                                  // Confirm Password Field
                                  TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: buildInputDecoration(
                                      'Confirm Password',
                                      const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_errorMessage.isNotEmpty) ...[
                                    SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 15),
                                  // Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => RegPage(
                                                  registrationData:
                                                      widget.registrationData,
                                                ),
                                              ),
                                            );
                                            
                                          },
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color.fromARGB(
                                                    255,
                                                    53,
                                                    122,
                                                    233,
                                                  ),
                                                  Color.fromARGB(
                                                    255,
                                                    113,
                                                    195,
                                                    230,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: _isLoading
                                                ? CircularProgressIndicator(
                                                    color: Colors.white,
                                                  )
                                                : Text(
                                                    'Back',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 35),

                                      SizedBox(
                                        width: 80,
                                        child: InkWell(
                                          onTap: () {
                                            if (_passwordController.text !=
                                                _confirmPasswordController
                                                    .text) {
                                              setState(() {
                                                _errorMessage =
                                                    "Passwords do not match";
                                              });
                                              return;
                                            }

                                            final updatedData = widget
                                                .registrationData
                                                .copyWith(
                                                  password:
                                                      _passwordController.text,
                                                  confirmPassword:
                                                      _confirmPasswordController
                                                          .text,
                                                );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PreviewPage(
                                                      registrationData:
                                                          updatedData,
                                                    ),
                                              ),
                                            );
                                          },

                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color.fromARGB(
                                                    255,
                                                    53,
                                                    122,
                                                    233,
                                                  ),
                                                  Color.fromARGB(
                                                    255,
                                                    113,
                                                    195,
                                                    230,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: _isLoading
                                                ? CircularProgressIndicator(
                                                    color: Colors.white,
                                                  )
                                                : Text(
                                                    'Next',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: Text(
                                        'Already have an account? Login',
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
                        ),
                        Spacer(),
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

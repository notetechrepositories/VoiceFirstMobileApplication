import 'dart:core';
import 'package:flutter/material.dart';
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Registration/preview_page.dart';
import 'package:voicefirst/Views/Registration/user_register_page2.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';
import 'package:voicefirst/Widgets/registerform.dart';
// import 'package:voicefirst/Views/RegistrationPage/registration_page.dart';

class PasswordPage extends StatefulWidget {
  // const PasswordPage({Key? key}) : super(key: key);

  final RegistrationData registrationData;

  const PasswordPage({super.key, required this.registrationData});

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final bool _isLoading = false;
  String _errorMessage = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordController.text = widget.registrationData.password;
    _confirmPasswordController.text = widget.registrationData.confirmPassword;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
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
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Register Account',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    StepBreadcrumb(
                                      currentStep: 2,
                                      steps: [
                                        'Basic',
                                        'Address',
                                        'Password',
                                        'Confirm',
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    Text(
                                      'Enter your Details below.',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),

                                    SizedBox(height: 20),
                                    // Password Field
                                    TextFormField(
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
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Password is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10),

                                    // Confirm Password Field
                                    TextFormField(
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
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Password is required';
                                        }
                                        return null;
                                      },
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
                                    SizedBox(height: 20),
                                    // Buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              12,
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
                                        SizedBox(width: 50),

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
                                                        _passwordController
                                                            .text,
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
                                              12,
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
                                                    BorderRadius.circular(12),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },

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
              );
            },
          ),
        ),
      ),
    );
  }
}

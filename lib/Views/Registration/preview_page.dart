import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';

class PreviewPage extends StatefulWidget {
  final RegistrationData registrationData;

  const PreviewPage({super.key, required this.registrationData});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool _isLoading = false;
  String _errorMessage = '';

  // Future<bool> registerUser(RegistrationData data) async {
  //   final url = Uri.parse('${ApiEndpoints.baseUrl}/Auth/register');
  //   debugPrint(jsonEncode(data.toJson()));
  //   //  Add this to log what you're sending to the server
  //   debugPrint("Payload sent to API:");

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data.toJson()),
  //     );
  //     debugPrint('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final responseBody = jsonDecode(response.body);
  //       // debugPrint(responseBody);

  //       return responseBody['isSuccess'] == true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint('Registration exception: $e');
  //     return false;
  //   }
  // }

  Future<Map<String, dynamic>> registerUser(RegistrationData data) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/Auth/register');
    debugPrint("Payload sent to API:");
    debugPrint(jsonEncode(data.toJson()));

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          'success': responseBody['isSuccess'] == true,
          'message': responseBody['message'] ?? 'Something went wrong',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Registration exception: $e');
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

  // void _onConfirm() async {
  //   setState(() => _isLoading = true);

  //   final success = await registerUser(widget.registrationData);
  //   setState(() => _isLoading = false);

  //   if (success) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginScreen()),
  //     );
  //   }
  // }
  void _onConfirm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final data = widget.registrationData;

    if (data.password != data.confirmPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    final result = await registerUser(data);

    setState(() {
      _isLoading = false;
      _errorMessage = result['success'] ? '' : result['message'];
    });

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.registrationData;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Confirm Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: StepBreadcrumb(
                            currentStep: 3,
                            steps: ['Basic', 'Address', 'Password', 'Confirm'],
                          ),
                        ),
                        const Divider(height: 30),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildRow("First Name", d.firstName),
                              buildRow("Last Name", d.lastName ?? ''),
                              buildRow("Email", d.email),
                              buildRow("Mobile", d.mobile),
                              buildRow("Gender", d.gender),
                              buildRow("Birth Year", d.birthYear.toString()),
                              const SizedBox(height: 10),
                              buildRow("Address 1", d.addressOne),
                              buildRow("Address 2", d.addressTwo ?? ''),
                              buildRow("Country", d.countryLabel),
                              buildRow("Division 1", d.divisionOneLabel),
                              buildRow("Division 2", d.divisionTwoLabel),
                              buildRow("Division 3", d.divisionThreeLabel),
                              buildRow("Place", d.place),
                              buildRow("Zip Code", d.zipCode),

                              if (_errorMessage.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        //buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 53, 122, 233),
                                        Color.fromARGB(255, 113, 195, 230),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 40),
                            SizedBox(
                              width: 100,
                              child: InkWell(
                                onTap: _isLoading ? null : _onConfirm,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 53, 122, 233),
                                        Color.fromARGB(255, 113, 195, 230),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Confirm',
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

                        const SizedBox(height: 20),
                        Center(
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
              ),
            );
          },
        ),
      ),
    );
  }
}

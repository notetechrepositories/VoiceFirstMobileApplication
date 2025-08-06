import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';

class PreviewPage extends StatefulWidget {
  final RegistrationData registrationData;

  final CountryModel selectedCountry;

  const PreviewPage({
    super.key,
    required this.registrationData,
    required this.selectedCountry,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool _isLoading = false;
  String _errorMessage = '';

  
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
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': responseBody['isSuccess'] == true,
          'message': responseBody['message'] ?? 'Registration successful!',
          'data': responseBody['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseBody['message'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Registration exception: $e');
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

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
      _errorMessage = result['success']
          ? ''
          : (result['message'] ?? 'Registration failed');
    });

    if (result['success']) {
      // ✅ Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registered successfully.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // ⏳ Optional wait before navigation
      await Future.delayed(const Duration(seconds: 2));

      // ✅ Navigate to login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  Widget buildPreviewField(String label, String? value) {
    if (value == null || value.trim().isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 120, // fixed width for labels
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // Value styled like a read-only text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
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
                             
                              buildPreviewField("First Name", d.firstName),
                              buildPreviewField("Last Name", d.lastName),
                              buildPreviewField("Email", d.email),
                              buildPreviewField(
                                "Mobile",
                                '${d.countryCodeLabel} ${d.mobile}',
                              ),
                              buildPreviewField("Gender", d.gender),
                              buildPreviewField(
                                "Birth Year",
                                d.birthYear.toString(),
                              ),
                              buildPreviewField("Address 1", d.addressOne),
                              buildPreviewField("Address 2", d.addressTwo),
                              buildPreviewField("Country", d.countryLabel),

                              buildPreviewField(
                                widget.selectedCountry.divisionOneLabel ??
                                    "Division 1",
                                widget.registrationData.divisionOneLabel,
                              ),
                              buildPreviewField(
                                widget.selectedCountry.divisionTwoLabel ??
                                    "Division 2",
                                widget.registrationData.divisionTwoLabel,
                              ),
                              buildPreviewField(
                                widget.selectedCountry.divisionThreeLabel ??
                                    "Division 3",
                                widget.registrationData.divisionThreeLabel,
                              ),

                              buildPreviewField("Place", d.place),
                              buildPreviewField("Zip Code", d.zipCode),

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

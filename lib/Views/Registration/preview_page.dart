// //designed
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:voicefirst/Core/Constants/api_endpoins.dart';
// import 'package:voicefirst/Models/registration_model.dart';
// import 'package:voicefirst/Views/LoginPage/login_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:voicefirst/Widgets/number_breadcrumb.dart';

// class PreviewPage extends StatefulWidget {
//   final RegistrationData registrationData;

//   const PreviewPage({Key? key, required this.registrationData})
//     : super(key: key);

//   @override
//   State<PreviewPage> createState() => _PreviewPageState();
// }

// class _PreviewPageState extends State<PreviewPage> {
//   bool _isLoading = false;
//   String _errorMessage = '';

//   Future<bool> registerUser(RegistrationData data) async {
//     final url = Uri.parse('${ApiEndpoints.baseUrl}/Auth/register');

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(data.toJson()),
//       );

//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);
//         return responseBody['status'] == 200;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }

//   void _onConfirm() async {
//     setState(() => _isLoading = true);

//     final success = await registerUser(widget.registrationData);

//     setState(() => _isLoading = false);

//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     } else {
//       setState(() {
//         _errorMessage = 'Registration failed. Please try again.';
//       });
//     }
//   }

//   Widget buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               "$label:",
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//                 color: Colors.grey[800],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(fontSize: 16, color: Colors.grey[900]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final d = widget.registrationData;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.05,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               StepBreadcrumb(
//                 currentStep: 3,
//                 steps: ['Basic', 'Address', 'Password', 'Confirm'],
//               ),
//               const SizedBox(height: 24),

//               // Section Title
//               Text(
//                 'Review Your Details',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),

//               // Info Rows
//               buildRow("First Name", d.firstName),
//               buildRow("Last Name", d.lastName),
//               buildRow("Email", d.email),
//               buildRow("Mobile", d.Mobile),
//               buildRow("Gender", d.gender),
//               buildRow("Birth Year", d.birthYear.toString()),
//               buildRow("Address 1", d.AddressOne),
//               buildRow("Address 2", d.address2),
//               buildRow("Country", d.country),
//               buildRow("Division 1", d.divisionOne),
//               buildRow("Division 2", d.divisionTwo),
//               buildRow("Division 3", d.divisionThree),
//               buildRow("Place", d.place),
//               buildRow("Zip Code", d.zipCode),
//               const SizedBox(height: 20),

//               if (_errorMessage.isNotEmpty)
//                 Text(
//                   _errorMessage,
//                   style: TextStyle(color: Colors.red, fontSize: 16),
//                 ),

//               const SizedBox(height: 30),

//               // Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 225, 168, 11),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 14,
//                       ),
//                     ),
//                     child: const Text("Back"),
//                   ),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _onConfirm,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 225, 168, 11),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 14,
//                       ),
//                     ),
//                     child: _isLoading
//                         ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text("Confirm & Register"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';

class PreviewPage extends StatefulWidget {
  final RegistrationData registrationData;

  const PreviewPage({Key? key, required this.registrationData})
    : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool _isLoading = false;
  String _errorMessage = '';

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
        return responseBody['status'] == 200;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _onConfirm() async {
    setState(() => _isLoading = true);
    final success = await registerUser(widget.registrationData);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      setState(() => _errorMessage = 'Registration failed. Please try again.');
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
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.registrationData;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
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
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            // elevation: 8,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(20),
                            // ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Confirm Details',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  StepBreadcrumb(
                                    currentStep: 3,
                                    steps: [
                                      'Basic',
                                      'Address',
                                      'Password',
                                      'Confirm',
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 10),
                                  buildRow("First Name", d.firstName),
                                  buildRow("Last Name", d.lastName ?? ''),
                                  buildRow("Email", d.email),
                                  buildRow("Mobile", d.mobile),
                                  buildRow("Gender", d.gender),
                                  buildRow(
                                    "Birth Year",
                                    d.birthYear.toString(),
                                  ),

                                  buildRow("Address 1", d.addressOne),
                                  buildRow("Address 2", d.addressTwo ?? ''),
                                  buildRow("Country", d.country),
                                  buildRow("Division 1", d.divisionOne),
                                  buildRow("Division 2", d.divisionTwo),
                                  buildRow("Division 3", d.divisionThree),
                                  buildRow("Place", d.place),
                                  buildRow("Zip Code", d.zipCode),
                                  const SizedBox(height: 10),
                                  if (_errorMessage.isNotEmpty)
                                    Text(
                                      _errorMessage,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            245,
                                            198,
                                            57,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Back"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            245,
                                            198,
                                            57,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : _onConfirm,
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text("Confirm & Register"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
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

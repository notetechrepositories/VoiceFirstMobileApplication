import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Registration/test.dart';
import 'package:voicefirst/Views/Registration/user_register_page1.dart';
import 'package:voicefirst/Views/Registration/user_register_page3.dart';
import 'package:voicefirst/Widgets/bread_crumb.dart';
import 'package:voicefirst/Widgets/registerform.dart';
// import 'package:voicefirst/Views/RegistrationPage/registration_page.dart';

class RegPage extends StatefulWidget {
  const RegPage({Key? key}) : super(key: key);

  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _div1Controller = TextEditingController();
  final TextEditingController _div2Controller = TextEditingController();
  final TextEditingController _div3Controller = TextEditingController();
  final TextEditingController _localController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  // String? _selectedValue;
  String? _selectedCountry;

  // List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> divisions = [];
  List<Map<String, dynamic>> filteredDivisions = [];

  List<CountryModel> countries = [];
  List<CountryModel> filteredCountries = [];
  bool isDataLoaded = false;
  String query = '';

  // fetch from api
  // getallcountries
  Future<void> getallCountries() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        //using model
        final fetched = dataList
            .map((countryJson) => CountryModel.fromJson(countryJson))
            .toList();

        setState(() {
          countries = fetched;
          // filteredCountries = List.from(fetched);
          filteredCountries = countries
              .where((c) => c.country.toLowerCase().contains(query))
              .toList();

          isDataLoaded = true;
          print(countries);
        });
      } else {
        debugPrint('failed to fetch countries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception Occured : $e');
    }
  }

  // Register function
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final address1 = _address1Controller.text.trim();
    final address2 = _address2Controller.text.trim();
    final country = _selectedCountry ?? '';
    final zipCode = _zipCodeController.text.trim();
    final div1 = _div1Controller.text.trim();
    final div2 = _div2Controller.text.trim();
    final div3 = _div3Controller.text.trim();
    final local = _localController.text.trim();

    // Validate input
    if (address1.isEmpty ||
        address2.isEmpty ||
        country.isEmpty ||
        zipCode.isEmpty ||
        div1.isEmpty ||
        div2.isEmpty ||
        div3.isEmpty ||
        local.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
        _isLoading = false;
      });
      return;
    }

    try {
      // Save data to SharedPreferences (Simulate successful registration)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('address1', address1);
      await prefs.setString('address2', address2);
      await prefs.setString('zipCode', zipCode);
      await prefs.setString('country', country);
      await prefs.setString('div1', div1);
      await prefs.setString('div2', div2);
      await prefs.setString('div3', div3);
      await prefs.setString('local', local);
      await prefs.setBool('isLoggedIn', true); // Simulate logged-in state

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // fetchCountries(); // Fetch countries when the page loads
    getallCountries();
  }

  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
                                  ArrowBreadcrumb(
                                    steps: ["Basic", "Address", "Password"],
                                    currentIndex:
                                        1, // or 1 or 2 depending on the page
                                    onTap: (index) {},
                                  ),

                                  // First Name
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: buildInputDecoration(
                                      "AddressLine 1",
                                      Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Last Name
                                  TextField(
                                    controller: _address2Controller,
                                    decoration: buildInputDecoration(
                                      "AddressLine 2",
                                      Icon(Icons.maps_home_work_outlined),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  //COUNTRY DIV1,DIV2,DIV3
                                  // Country
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: buildInputDecoration(
                                      'Country',
                                      Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Division1
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: buildInputDecoration(
                                      'Division 1',
                                      Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Division2
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: buildInputDecoration(
                                      'Division2',
                                      Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Division3
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: buildInputDecoration(
                                      'Division3',
                                      Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Place
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: buildInputDecoration(
                                      'Place',
                                      Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // zipCode
                                  TextField(
                                    controller: _zipCodeController,
                                    decoration: buildInputDecoration(
                                      'ZipCode',
                                      Icon(Icons.mail_rounded),
                                    ),
                                  ),
                                  SizedBox(height: 15),

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
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistrationPage(),
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
                                      SizedBox(width: 55),
                                      SizedBox(
                                        width: 80,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PasswordPage(),
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

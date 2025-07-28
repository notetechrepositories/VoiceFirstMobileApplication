import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
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
  String? _selectedDiv1;

  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> divisions = [];
  List<Map<String, dynamic>> filteredDivisions = [];

  bool _isLoadingCountries = false;
  bool _isLoadingDivisions = false;

  // fetch from api

  Future<void> fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });

    final url = 'http://10.0.2.2:5132/api/country/get-all';
    final filter = {};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(filter),
      );

      // final response = await http.post(Uri.parse(url),);

      // Print the raw response to check what you're receiving
      // print('Response body: ${response.body}'); // Debugging line

      final responseData = jsonDecode(response.body);
      if (responseData['data'] != null &&
          responseData['data']['Items'] != null) {
        final List<Map<String, dynamic>> fetchedCountries = [];
        for (var country in responseData['data']['Items']) {
          fetchedCountries.add(country);
        }
        setState(() {
          countries = fetchedCountries; // storing countries
          _selectedCountry = countries.isNotEmpty
              ? countries[0]['t2_1_country_name']
              : null; // Default to first country if available
        });
      }
    } catch (error) {
      print('Failed to load countries : $error');
      setState(() {
        _isLoadingCountries = false;
        _errorMessage = 'failed toload countries';
      });
    }
  }

  //fetchinng division1 for selected country
  Future<void> _fetchDivisions(String countryId) async {
    setState(() {
      _isLoadingDivisions = true;
      divisions.clear(); // to clear previous divisions
      filteredDivisions.clear();
    });

    final url = 'http://localhost:5132/api/division/get-all-division-one';
    try {
      //   final response = await http.post(Uri.parse(url));

      //   final responseData = jsonDecode(response.body);

      // }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "filters": {"t2_1_country_id": countryId},
        }),
      );
      final responseData = jsonDecode(response.body);

      final List<Map<String, dynamic>> fetchedDivisions = [];

      for (var division in responseData['data']['Items']) {
        fetchedDivisions.add(division);
      }

      setState(() {
        divisions = fetchedDivisions;

        // filteredDivisions = divisions.where((division)=> division['t2_1_'])
      });
    } catch (e) {
      return;
    }
  }
  // Date Picker Function

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
    fetchCountries(); // Fetch countries when the page loads
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
                        SizedBox(height: screenHeight * 0.08),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.10,
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
                                  // First Name
                                  TextField(
                                    controller: _address1Controller,
                                    decoration: InputDecoration(
                                      labelText: 'AddressLine 1',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.home),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Last Name
                                  TextField(
                                    controller: _address2Controller,
                                    decoration: InputDecoration(
                                      labelText: 'AddressLine 2',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        Icons.maps_home_work_outlined,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // zipCode
                                  TextField(
                                    controller: _zipCodeController,
                                    decoration: InputDecoration(
                                      labelText: 'ZipCode',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.mail_rounded),
                                    ),
                                  ),
                                  SizedBox(height: 15),

                                  // country Number
                                  // TextField(
                                  //   controller: _countryController,
                                  //   decoration: InputDecoration(
                                  //     labelText: 'Country',
                                  //     border: OutlineInputBorder(),
                                  //     prefixIcon: Icon(
                                  //       Icons.location_on_outlined,
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(height: 15),

                                  // DropdownButton<String>(
                                  //   value: _selectedCountry,
                                  //   hint: Text(
                                  //     "Select country",
                                  //     isExpanded:true,

                                  //   onChanged: (String? newValue) {
                                  //     setState(() {
                                  //       _selectedCountry = newValue;
                                  //     });
                                  //   },
                                  //   items:
                                  //       <String>[
                                  //         'Option 1',
                                  //         'Option 2',
                                  //         'Option 3',
                                  //         'Option 4',
                                  //       ].map<DropdownMenuItem<String>>((
                                  //         String value,
                                  //       ) {
                                  //         return DropdownMenuItem<String>(
                                  //           value: value,
                                  //           child: Row(
                                  //             children: [
                                  //               Icon(
                                  //                 Icons.check,
                                  //                 color: Colors.green,
                                  //               ), // Custom icon for each item
                                  //               SizedBox(width: 8),
                                  //               Text(value),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       }).toList(),
                                  //   // Makes the dropdown take up all available width
                                  //   // underline:       Container(), // Removes the default underline
                                  //   style: TextStyle(
                                  //     color: Colors.black,
                                  //     fontSize: 18,
                                  //   ),
                                  // ),
                                  // Country Dropdown
                                  DropdownButton<String>(
                                    value: _selectedCountry,
                                    hint: Text("--Select Country--"),
                                    isExpanded:
                                        true, // Makes dropdown occupy full width
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCountry = newValue;
                                      });
                                    },
                                    items: countries
                                        .map<DropdownMenuItem<String>>((
                                          country,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: country['t2_1_country_name'],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              child: Text(
                                                country['t2_1_country_name'],
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                    icon: Icon(Icons.arrow_drop_down),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    underline: Container(),
                                    dropdownColor: Colors.white,
                                    elevation: 5,
                                  ),

                                  // dropdownMaxHeight :300,
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
                                  // Register Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: InkWell(
                                          onTap: () {},
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

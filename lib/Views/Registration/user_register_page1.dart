import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Registration/user_register_page2.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';
import 'package:voicefirst/Widgets/registerform.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';

class RegistrationPage extends StatefulWidget {
  final RegistrationData? registrationData;

  const RegistrationPage({super.key, this.registrationData});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();

   Future<void> getallCountries({required bool prefill}) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((countryJson) => CountryModel.fromJson(countryJson))
            .toList();

        
      } else {
        debugPrint('failed to fetch countries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception Occured : $e');
    }
  }


  final List<Map<String, String>> _countryCodes = [
    {'name': 'India', 'code': '+91'},
    {'name': 'USA', 'code': '+1'},
    {'name': 'UK', 'code': '+44'},
    {'name': 'UAE', 'code': '+971'},
  ];

  String _selectedCountryCode = '+91'; // default

  RegistrationData registrationData = RegistrationData(
    firstName: '',
    lastName: '',
    addressOne: '',
    addressTwo: '',
    mobile: '',
    zipCode: '',
    email: '',
    birthYear: 0,
    gender: '',
    countryId: '',
    countryLabel: '',
    countryCode : '',
    divisionOneId: '',
    divisionOneLabel: '',
    divisionTwoId: '',
    divisionTwoLabel: '',
    divisionThreeId: '',
    divisionThreeLabel: '',
    place: '',
    password: '',
    confirmPassword: '',
  );

  String _selectedGender = "Male"; // Default gender
  final bool _isLoading = false;
  final String _errorMessage = '';

  Future<void> _selectBirthYear(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final firstYear = 1900;

    int selectedYear = currentYear;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Birth Year'),
          content: Container(
            height: 300,
            width: 100,
            child: YearPicker(
              firstDate: DateTime(firstYear),
              lastDate: DateTime(currentYear),
              initialDate: DateTime(selectedYear),
              selectedDate:
                  DateTime.tryParse(_birthYearController.text) ??
                  DateTime(currentYear),
              onChanged: (DateTime dateTime) {
                setState(() {
                  _birthYearController.text = dateTime.year.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    registrationData =
        widget.registrationData ??
        RegistrationData(
          firstName: '',
          lastName: null,
          addressOne: '',
          addressTwo: null,
          mobile: '',
          zipCode: '',
          email: '',
          birthYear: 0, // 0 means not selected
          gender: '',
          countryId: '',
          countryLabel: '',
          countryCode:'',
          divisionOneId: '',
          divisionOneLabel: '',
          divisionTwoId: '',
          divisionTwoLabel: '',
          divisionThreeId: '',
          divisionThreeLabel: '',
          place: '',
          password: '',
          confirmPassword: '',
        );

    _firstNameController.text = registrationData.firstName;
    _lastNameController.text = registrationData.lastName ?? '';
    _emailController.text = registrationData.email;
    _mobileController.text = registrationData.mobile;

    // ✅ Only show birth year if it's not 0
    if (registrationData.birthYear != 0) {
      _birthYearController.text = registrationData.birthYear.toString();
    } else {
      _birthYearController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(child: SizedBox()), // top spacer
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),

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
                                    currentStep: 0,
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
                                  // First Name
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _firstNameController,
                                          decoration: buildInputDecoration(
                                            'First Name',
                                            Icon(Icons.person),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'first name is required';
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 10),
                                        // Last Name
                                        TextFormField(
                                          controller: _lastNameController,
                                          decoration: buildInputDecoration(
                                            'Last Name',
                                            Icon(Icons.person),
                                          ),
                                        ),

                                        SizedBox(height: 10),

                                        TextFormField(
                                          controller: _emailController,
                                          decoration: buildInputDecoration(
                                            'Email',
                                            Icon(Icons.email),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Email is required';
                                            }
                                            if (!RegExp(
                                              r'^[^@]+@[^@]+\.[^@]+',
                                            ).hasMatch(value)) {
                                              return 'Enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 10),
                                        //mibile num
                                        Row(
                                          children: [
                                            // Dropdown for country code
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: _selectedCountryCode,
                                                  items: _countryCodes.map((
                                                    country,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: country['code'],
                                                      child: Text(
                                                        '${country['code']}',
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedCountryCode =
                                                          value!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),

                                            // TextFormField for mobile number
                                            Expanded(
                                              child: TextFormField(
                                                controller: _mobileController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Mobile Number',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Mobile number is required';
                                                  }
                                                  if (!RegExp(
                                                    r'^[0-9]+$',
                                                  ).hasMatch(value)) {
                                                    return 'Only digits allowed';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),

                                        // Date of Birth
                                        GestureDetector(
                                          onTap: () =>
                                              _selectBirthYear(context),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: _birthYearController,
                                              decoration: InputDecoration(
                                                labelText: 'Date of Birth',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.calendar_today,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),

                                        // Gender Selection (Radio buttons)
                                        DropdownButtonHideUnderline(
                                          child: DropdownButtonFormField<String>(
                                            value: _selectedGender.isNotEmpty
                                                ? _selectedGender
                                                : null,
                                            decoration: buildInputDecoration(
                                              'Gender',

                                              Icon(Icons.person_outline),
                                            ),
                                            items: ['Male', 'Female', 'Other']
                                                .map((gender) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: gender,
                                                    child: Text(gender),
                                                  );
                                                })
                                                .toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedGender = newValue!;
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please select your gender';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        SizedBox(height: 10),
                                      ],
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
                                  // Register Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: InkWell(
                                          onTap: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final updatedData =
                                                  registrationData.copyWith(
                                                    firstName:
                                                        _firstNameController
                                                            .text
                                                            .trim(),
                                                    lastName:
                                                        _lastNameController.text
                                                            .trim(),
                                                    email: _emailController.text
                                                        .trim(),
                                                    mobile: _mobileController
                                                        .text
                                                        .trim(),
                                                    birthYear:
                                                        int.tryParse(
                                                          _birthYearController
                                                              .text
                                                              .trim(),
                                                        ) ??
                                                        0,

                                                    gender: _selectedGender,
                                                  );
                                              if (_selectedGender.isEmpty) {
                                                SnackbarHelper.showError(
                                                  'select a gender',
                                                );
                                                return; // Prevent navigation
                                              }

                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          RegPage(
                                                            registrationData:
                                                                updatedData,
                                                          ),
                                                    ),
                                                  );

                                              if (result is RegistrationData) {
                                                setState(() {
                                                  registrationData = result;

                                                  // Optional: Update controllers to reflect returned data
                                                  _firstNameController.text =
                                                      result.firstName;
                                                  _lastNameController.text =
                                                      result.lastName ?? '';
                                                  _emailController.text =
                                                      result.email;
                                                  _mobileController.text =
                                                      result.mobile;
                                                  _birthYearController.text =
                                                      result.birthYear != 0
                                                      ? result.birthYear
                                                            .toString()
                                                      : '';

                                                  _selectedGender =
                                                      result.gender;
                                                });
                                              }
                                            }
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
                                ],
                              ),
                            ),
                          ),
                          //card
                        ),
                        Expanded(child: SizedBox()), // bottom spacer

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
                            padding: const EdgeInsets.only(left: 10, right: 10),
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

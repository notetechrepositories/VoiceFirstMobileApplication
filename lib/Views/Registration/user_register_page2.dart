import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Models/division_one_model.dart';
import 'package:voicefirst/Models/division_three_model.dart';
import 'package:voicefirst/Models/division_two_model.dart';
import 'package:voicefirst/Models/registration_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Registration/user_register_page1.dart';
import 'package:voicefirst/Views/Registration/user_register_page3.dart';
import 'package:voicefirst/Widgets/number_breadcrumb.dart';
import 'package:voicefirst/Widgets/registerform.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';

class RegPage extends StatefulWidget {
  final RegistrationData registrationData;

  const RegPage({super.key, required this.registrationData});

  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _div1Controller = TextEditingController();
  final TextEditingController _div2Controller = TextEditingController();
  final TextEditingController _div3Controller = TextEditingController();
  final TextEditingController _localController = TextEditingController();

  final bool _isLoading = false;
  final String _errorMessage = '';

  late RegistrationData registrationData;

  CountryModel? selectedCountry;
  DivisionOneModel? selectedDiv1;
  DivisionTwoModel? selectedDiv2;
  DivisionThreeModel? selectedDiv3;

  List<DivisionOneModel> divisionOneList = [];
  List<DivisionOneModel> filteredDivOne = [];

  // Model lists
  List<DivisionTwoModel> divisionTwoList = [];
  List<DivisionThreeModel> divisionThreeList = [];
  List<CountryModel> countries = [];
  List<CountryModel> filteredCountries = [];
  bool isDataLoaded = false;
  String query = '';

  //get all countries
  Future<void> getallCountries({required bool prefill}) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList.map((e) => CountryModel.fromJson(e)).toList();

        setState(() {
          countries = fetched;
          filteredCountries = fetched;
          isDataLoaded = true;

          getAllDivisionOnes(prefill: false); // move this outside setState
        });

        if (selectedCountry != null) {
          await getAllDivisionOnes(prefill: prefill);
        }
      } else {
        debugPrint('failed to fetch countries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception Occured : $e');
    }
  }

  //division 1
  Future<void> getAllDivisionOnes({required bool prefill}) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/division-one/all?country=${selectedCountry?.id}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((e) => DivisionOneModel.fromJson(e))
            .toList();

        setState(() {
          divisionOneList = fetched;
          filteredDivOne = List.from(divisionOneList);
          isDataLoaded = true;

          // if (prefill && registrationData.divisionOneId.isNotEmpty) {
          //   selectedDiv1 = divisionOneList.firstWhere(
          //     (d) => d.id == registrationData.divisionOneId,
          //     orElse: () => fetched.first,
          //   );
          // }
          if (prefill && registrationData.divisionOneId.isNotEmpty) {
            final match = fetched.where(
              (d) => d.id == registrationData.divisionOneId,
            );
            if (match.isNotEmpty) {
              selectedDiv1 = match.first;
            } else {
              selectedDiv1 = null;
            }
          }
        });

        // if (selectedDiv1 != null) {
        //   await getAllDivisionTwos(
        //     prefill: prefill,
        //     divisionOneId: selectedDiv1!.id,
        //   );
        // }
        if (divisionOneList.isEmpty) {
          setState(() {
            selectedDiv1 = null;
            selectedDiv2 = null;
            selectedDiv3 = null;
            divisionTwoList.clear();
            divisionThreeList.clear();
          });
          return; // Stop here since no divisions are available
        }

        if (selectedDiv1 != null) {
          await getAllDivisionTwos(
            prefill: prefill,
            divisionOneId: selectedDiv1!.id,
          );
        }
      } else {
        debugPrint('Failed to fetch Division One: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Division One: $e');
    }
  }

  // division2
  Future<void> getAllDivisionTwos({
    required bool prefill,
    required String divisionOneId,
  }) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/division-two/all?divisionOne=$divisionOneId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((e) => DivisionTwoModel.fromJson(e))
            .toList();

        setState(() {
          divisionTwoList = fetched;

          // if (prefill && registrationData.divisionTwoId.isNotEmpty) {
          //   selectedDiv2 = divisionTwoList.firstWhere(
          //     (d) => d.id == registrationData.divisionTwoId,
          //     orElse: () => fetched.first,
          //   );
          // }
          if (prefill && registrationData.divisionTwoId.isNotEmpty) {
            final match = fetched.where(
              (d) => d.id == registrationData.divisionTwoId,
            );
            if (match.isNotEmpty) {
              selectedDiv2 = match.first;
            } else {
              selectedDiv2 = null;
            }
          }
        });

        if (selectedDiv2 != null) {
          await getAllDivisionThrees(
            prefill: prefill,
            divisionTwoId: selectedDiv2!.id,
          );
        }
      } else {
        debugPrint('Failed to fetch Division Two: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Division Two: $e');
    }
  }

  //division 3

  Future<void> getAllDivisionThrees({
    required bool prefill,
    required String divisionTwoId,
  }) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/division-three/all?divisionTwo=$divisionTwoId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((e) => DivisionThreeModel.fromJson(e))
            .toList();

        setState(() {
          divisionThreeList = fetched;

          // if (prefill && registrationData.divisionThreeId.isNotEmpty) {
          //   selectedDiv3 = divisionThreeList.firstWhere(
          //     (d) => d.id == registrationData.divisionThreeId,
          //     orElse: () => fetched.first,
          //   );
          // }
          if (prefill && registrationData.divisionThreeId.isNotEmpty) {
            final match = fetched.where(
              (d) => d.id == registrationData.divisionThreeId,
            );
            if (match.isNotEmpty) {
              selectedDiv3 = match.first;
            } else {
              selectedDiv3 = null;
            }
          }
        });
      } else {
        debugPrint('Failed to fetch Division Three: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Division Three: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    registrationData = widget.registrationData;

    _address1Controller.text = registrationData.addressOne;
    _address2Controller.text = registrationData.addressTwo ?? '';
    _zipCodeController.text = registrationData.zipCode;
    _localController.text = registrationData.place;

    // Check if country is already selected → we are returning from Page 1 or 3
    if (registrationData.countryId.isNotEmpty) {
      selectedCountry = CountryModel(
        id: registrationData.countryId,
        country: registrationData.countryLabel,
        countryCode: registrationData.countryCodeLabel,
        divisionOneLabel: registrationData.divisionOneLabel,
        divisionTwoLabel: registrationData.divisionTwoLabel,
        divisionThreeLabel: registrationData.divisionThreeLabel,
      );

      getallCountries(prefill: true); // pre-fill divisions too
    } else {
      // First time — show hint only
      getallCountries(prefill: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                                  mainAxisSize: MainAxisSize.min,
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
                                      currentStep: 1,
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
                                    TextFormField(
                                      controller: _address1Controller,
                                      decoration: buildInputDecoration(
                                        "AddressLine 1",
                                        Icon(Icons.home),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'address  is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    // Last Name
                                    TextFormField(
                                      controller: _address2Controller,
                                      decoration: buildInputDecoration(
                                        "AddressLine 2",
                                        Icon(Icons.maps_home_work_outlined),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    //COUNTRY DIV1,DIV2,DIV3
                                    // Country
                                    DropdownButtonFormField<CountryModel>(
                                      value: selectedCountry,
                                      hint: Text("Select Country"),
                                      decoration: buildInputDecoration(
                                        'Country',
                                        Icon(Icons.map),
                                      ),
                                      items: countries.map((country) {
                                        return DropdownMenuItem<CountryModel>(
                                          value: country,
                                          child: Text(country.country),
                                        );
                                      }).toList(),

                                      onChanged: (CountryModel? newValue) {
                                        if (newValue == null) return;
                                        setState(() {
                                          selectedCountry = newValue;
                                          selectedDiv1 = null;
                                          selectedDiv2 = null;
                                          selectedDiv3 = null;
                                          _div1Controller.clear();
                                          _div2Controller.clear();
                                          _div3Controller.clear();
                                          divisionOneList.clear();
                                          divisionTwoList.clear();
                                          divisionThreeList.clear();
                                        });

                                        getAllDivisionOnes(
                                          prefill: false,
                                        ); // move this outside setState
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'select a country required';
                                        }
                                        return null;
                                      },
                                    ),

                                    // // Division 1 Dropdown
                                    if (selectedCountry != null &&
                                        divisionOneList.isNotEmpty) ...[
                                      SizedBox(height: 10),
                                      DropdownButtonFormField<DivisionOneModel>(
                                        value: selectedDiv1,
                                        // hint: Text(
                                        //   selectedCountry?.divisionOneLabel ??
                                        //       "--Select--",
                                        // ),
                                        hint: Text(
                                          selectedCountry?.divisionOneLabel ??
                                              "--Select--",
                                        ),

                                        decoration: buildInputDecoration(
                                          selectedCountry?.divisionOneLabel ??
                                              "--Select--",
                                          Icon(Icons.share_location_outlined),
                                        ),
                                        items: divisionOneList.map((div) {
                                          return DropdownMenuItem<
                                            DivisionOneModel
                                          >(
                                            value: div,
                                            child: Text(div.divisionOne),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDiv1 = value!;
                                            _div1Controller.text =
                                                value.divisionOne;
                                            selectedDiv2 = null;
                                            selectedDiv3 = null;
                                            _div2Controller.clear();
                                            _div3Controller.clear();
                                            divisionTwoList.clear();
                                            divisionThreeList.clear();
                                            getAllDivisionTwos(
                                              prefill: false,
                                              divisionOneId: value.id,
                                            );
                                          });
                                        },
                                      ),
                                    ],

                                    //division2
                                    if (selectedDiv1 != null &&
                                        divisionTwoList.isNotEmpty) ...[
                                      SizedBox(height: 10),

                                      DropdownButtonFormField<DivisionTwoModel>(
                                        value: selectedDiv2,
                                        hint: Text(
                                          selectedCountry?.divisionTwoLabel ??
                                              "--Select--",
                                        ),
                                        decoration: buildInputDecoration(
                                          selectedCountry?.divisionTwoLabel ??
                                              "--Select--",
                                          Icon(Icons.share_location_outlined),
                                        ),
                                        items: divisionTwoList.map((div) {
                                          return DropdownMenuItem<
                                            DivisionTwoModel
                                          >(
                                            value: div,
                                            child: Text(div.divisionTwo),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDiv2 = value!;
                                            _div2Controller.text =
                                                value.divisionTwo;
                                            selectedDiv3 = null;
                                            _div3Controller.clear();
                                            divisionThreeList.clear();
                                            getAllDivisionThrees(
                                              prefill: false,
                                              divisionTwoId: value.id,
                                            );
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return "This field is required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ],

                                    // Division 3 Dropdown
                                    if (selectedDiv2 != null &&
                                        divisionThreeList.isNotEmpty) ...[
                                      SizedBox(height: 10),

                                      DropdownButtonFormField<
                                        DivisionThreeModel
                                      >(
                                        value: selectedDiv3,
                                        hint: Text(
                                          selectedCountry?.divisionThreeLabel ??
                                              "--Select--",
                                        ),
                                        decoration: buildInputDecoration(
                                          selectedCountry?.divisionThreeLabel ??
                                              "--Select--",
                                          Icon(Icons.share_location_outlined),
                                        ),
                                        items: divisionThreeList.map((div) {
                                          return DropdownMenuItem<
                                            DivisionThreeModel
                                          >(
                                            value: div,
                                            child: Text(div.divisionThree),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDiv3 = value!;
                                            _div3Controller.text =
                                                value.divisionThree;
                                          });
                                        },
                                      ),
                                    ],

                                    SizedBox(height: 10),
                                    // Place
                                    TextFormField(
                                      controller: _localController,
                                      decoration: buildInputDecoration(
                                        'Place',
                                        Icon(Icons.location_city),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // zipCode
                                    TextFormField(
                                      controller: _zipCodeController,
                                      decoration: buildInputDecoration(
                                        'ZipCode',
                                        Icon(Icons.mail_rounded),
                                      ),
                                    ),
                                    SizedBox(height: 10),

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
                                              final updatedData =
                                                  registrationData.copyWith(
                                                    addressOne:
                                                        _address1Controller.text
                                                            .trim(),
                                                    addressTwo:
                                                        _address2Controller.text
                                                            .trim(),
                                                    zipCode: _zipCodeController
                                                        .text
                                                        .trim(),
                                                    place: _localController.text
                                                        .trim(),

                                                    countryCode:
                                                        registrationData
                                                            .countryCode,
                                                    countryCodeLabel:
                                                        registrationData
                                                            .countryCodeLabel,

                                                    divisionOneId:
                                                        selectedDiv1?.id ?? '',
                                                    divisionTwoId:
                                                        selectedDiv2?.id ?? '',
                                                    divisionThreeId:
                                                        selectedDiv3?.id ?? '',

                                                    divisionOneLabel:
                                                        selectedCountry
                                                            ?.divisionOneLabel ??
                                                        '',
                                                    divisionTwoLabel:
                                                        selectedCountry
                                                            ?.divisionTwoLabel ??
                                                        '',
                                                    divisionThreeLabel:
                                                        selectedCountry
                                                            ?.divisionThreeLabel ??
                                                        '',
                                                  );

                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegistrationPage(
                                                        registrationData:
                                                            updatedData,

                                                        //optionally we can pass country
                                                      ),
                                                ),
                                              );
                                            },

                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 14,
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
                                              final form =
                                                  _formKey.currentState;
                                              if (form != null &&
                                                  form.validate()) {
                                                if (selectedCountry == null) {
                                                  setState(() {
                                                    SnackbarHelper.showError(
                                                      'select a country',
                                                    );
                                                  });
                                                }
                                                final updatedData =
                                                    registrationData.copyWith(
                                                      addressOne:
                                                          _address1Controller
                                                              .text
                                                              .trim(),
                                                      addressTwo:
                                                          _address2Controller
                                                              .text
                                                              .trim(),
                                                      zipCode:
                                                          _zipCodeController
                                                              .text
                                                              .trim(),
                                                      place: _localController
                                                          .text
                                                          .trim(),
                                                      countryId:
                                                          selectedCountry?.id ??
                                                          '',
                                                      countryLabel:
                                                          selectedCountry
                                                              ?.country ??
                                                          '',

                                                      divisionOneId:
                                                          selectedDiv1?.id ??
                                                          '',
                                                      divisionOneLabel:
                                                          selectedDiv1
                                                              ?.divisionOne ??
                                                          '',
                                                      divisionTwoId:
                                                          selectedDiv2?.id ??
                                                          '',
                                                      divisionTwoLabel:
                                                          selectedDiv2
                                                              ?.divisionTwo ??
                                                          '',
                                                      divisionThreeId:
                                                          selectedDiv3?.id ??
                                                          '',
                                                      divisionThreeLabel:
                                                          selectedDiv3
                                                              ?.divisionThree ??
                                                          '',
                                                    );

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PasswordPage(
                                                          registrationData:
                                                              updatedData,
                                                          selectedCountry:
                                                              selectedCountry!,
                                                        ),
                                                  ),
                                                );
                                              }
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

                        // Spacer(),
                        SizedBox(height: 20),
                        TextButton(
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

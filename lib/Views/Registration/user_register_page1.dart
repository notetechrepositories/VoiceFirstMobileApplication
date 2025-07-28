import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Registration/user_register_page2.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedGender = "Male"; // Default gender
  bool _isLoading = false;
  String _errorMessage = '';

  // Date Picker Function
  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Color.fromARGB(255, 245, 198, 57), // Accent color
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 245, 198, 57), // Header color
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              secondary: Color.fromARGB(
                255,
                252,
                237,
                155,
              ), // Selected date color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _birthYearController.text = "${selectedDate.toLocal()}".split(
          ' ',
        )[0]; // Format: YYYY-MM-DD
      });
    }
  }

  // Register function
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final birthYear = _birthYearController.text.trim();
    final sex = _selectedGender;
    final password = _passwordController.text.trim();

    // Validate input
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        mobile.isEmpty ||
        email.isEmpty ||
        birthYear.isEmpty ||
        sex.isEmpty ||
        password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
        _isLoading = false;
      });
      return;
    }

    try {
      // Save data to SharedPreferences (Simulate successful registration)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('firstName', firstName);
      await prefs.setString('lastName', lastName);
      await prefs.setString('email', email);
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
                                    controller: _firstNameController,
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Last Name
                                  TextField(
                                    controller: _lastNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Email
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Mobile Number
                                  TextField(
                                    controller: _mobileController,
                                    decoration: InputDecoration(
                                      labelText: 'Mobile Number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Date of Birth
                                  GestureDetector(
                                    onTap: () => _selectDateOfBirth(context),
                                    child: AbsorbPointer(
                                      child: TextField(
                                        controller: _birthYearController,
                                        decoration: InputDecoration(
                                          labelText: 'Date of Birth',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  // Gender Selection (Radio buttons)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Gender : ",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.05),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: "Male",
                                            groupValue: _selectedGender,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedGender = value!;
                                              });
                                            },
                                            activeColor: Color.fromARGB(
                                              255,
                                              245,
                                              198,
                                              57,
                                            ),
                                          ),
                                          Text(
                                            "Male",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.05),
                                          Radio<String>(
                                            value: "Female",
                                            groupValue: _selectedGender,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedGender = value!;
                                              });
                                            },
                                            activeColor: Color.fromARGB(
                                              255,
                                              245,
                                              198,
                                              57,
                                            ),
                                          ),
                                          Text(
                                            "Female",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  // Password
                                  // TextField(
                                  //   controller: _passwordController,
                                  //   obscureText: true,
                                  //   decoration: InputDecoration(
                                  //     labelText: 'Password',
                                  //     border: OutlineInputBorder(),
                                  //     prefixIcon: Icon(Icons.lock),
                                  //   ),
                                  // ),
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
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => RegPage(),
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

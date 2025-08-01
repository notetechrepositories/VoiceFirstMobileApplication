class RegistrationData {
  final String firstName;
  final String? lastName;
  final String addressOne;
  final String? addressTwo;
  final String mobile;
  final String zipCode;
  final String email;
  final int birthYear;
  final String gender;
  final String country;
  final String divisionOne;
  final String divisionTwo;
  final String divisionThree;
  final String place;
  final String password;
  final String confirmPassword;

  RegistrationData({
    required this.firstName,
     this.lastName,
    required this.addressOne,
     this.addressTwo,
    required this.mobile,
    required this.zipCode,
    required this.email,
    required this.birthYear,
    required this.gender,
    required this.country,
    required this.divisionOne,
    required this.divisionTwo,
    required this.divisionThree,
    required this.place,
    required this.password,
    required this.confirmPassword,
  });

  RegistrationData copyWith({
    String? firstName,
    String? lastName,
    String? addressOne,
    String? addressTwo,
    String? mobile,
    String? zipCode,
    String? email,
    int? birthYear,
    String? gender,
    String? country,
    String? divisionOne,
    String? divisionTwo,
    String? divisionThree,
    String? place,
    String? password,
    String? confirmPassword,
  }) {
    return RegistrationData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      addressOne: addressOne ?? this.addressOne,
      addressTwo: addressTwo ?? this.addressTwo,
      mobile: mobile ?? this.mobile,
      zipCode: zipCode ?? this.zipCode,
      email: email ?? this.email,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      divisionOne: divisionOne ?? this.divisionOne,
      divisionTwo: divisionTwo ?? this.divisionTwo,
      divisionThree: divisionThree ?? this.divisionThree,
      place: place ?? this.place,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName ?? '',
      'addressOne': addressOne,
      'addressTwo': addressTwo ?? '',
      'mobile': mobile,
      'zipCode': zipCode,
      'email': email,
      'birthYear': birthYear,
      'gender': gender,
      'country': country,
      'divisionOne': divisionOne,
      'divisionTwo': divisionTwo,
      'divisionThree': divisionThree,
      'place': place,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      firstName: json['firstName'],
      lastName: json['lastName'],
      addressOne: json['addressOne'],
      addressTwo: json['addressTwo'],
      mobile: json['mobile'],
      zipCode: json['zipCode'],
      email: json['email'],
      birthYear: json['birthYear'],
      gender: json['gender'],
      country: json['country'],
      divisionOne: json['divisionOne'],
      divisionTwo: json['divisionTwo'],
      divisionThree: json['divisionThree'],
      place: json['place'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
    );
  }
}

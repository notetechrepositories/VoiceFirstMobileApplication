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

  // Country & Divisions - both label and ID
  final String countryId;
  final String countryLabel;

  final String countryCode;
  final String countryCodeLabel;
  final String countryIsoCode;

  final String divisionOneId;
  final String divisionOneLabel;

  final String divisionTwoId;
  final String divisionTwoLabel;

  final String divisionThreeId;
  final String divisionThreeLabel;

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
    required this.countryId,
    required this.countryLabel,
    required this.countryCode,
    required this.countryCodeLabel,
    required this.countryIsoCode,
    required this.divisionOneId,
    required this.divisionOneLabel,
    required this.divisionTwoId,
    required this.divisionTwoLabel,
    required this.divisionThreeId,
    required this.divisionThreeLabel,
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
    String? countryId,
    String? countryLabel,
    String? countryCode,
    String? countryCodeLabel,
    String? countryIsoCode,
    String? divisionOneId,
    String? divisionOneLabel,
    String? divisionTwoId,
    String? divisionTwoLabel,
    String? divisionThreeId,
    String? divisionThreeLabel,
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
      countryId: countryId ?? this.countryId,
      countryLabel: countryLabel ?? this.countryLabel,
      countryCode: countryCode ?? this.countryCode,
      countryCodeLabel: countryCodeLabel ?? this.countryCodeLabel,
      countryIsoCode: countryIsoCode ?? this.countryIsoCode,
      divisionOneId: divisionOneId ?? this.divisionOneId,
      divisionOneLabel: divisionOneLabel ?? this.divisionOneLabel,
      divisionTwoId: divisionTwoId ?? this.divisionTwoId,
      divisionTwoLabel: divisionTwoLabel ?? this.divisionTwoLabel,
      divisionThreeId: divisionThreeId ?? this.divisionThreeId,
      divisionThreeLabel: divisionThreeLabel ?? this.divisionThreeLabel,
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
      'country': countryId,
      'countryCode': countryCode,
      'countryIsoCode':countryIsoCode,
      'divisionOne': divisionOneId,
      'divisionTwo': divisionTwoId,
      'divisionThree': divisionThreeId,
      'place': place,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      addressOne: json['addressOne'] ?? '',
      addressTwo: json['addressTwo'] ?? '',
      mobile: json['mobile'] ?? '',
      zipCode: json['zipCode'] ?? '',
      email: json['email'] ?? '',
      birthYear: json['birthYear'] ?? 0,
      gender: json['gender'] ?? '',
      countryId: json['country'] ?? '',
      countryLabel: '',
      countryCode: json['countryCode'] ?? '',
      countryCodeLabel: '',
      countryIsoCode: json['countryIsoCode'] ?? '',
      divisionOneId: json['divisionOne'] ?? '',
      divisionOneLabel: '',
      divisionTwoId: json['divisionTwo'] ?? '',
      divisionTwoLabel: '',
      divisionThreeId: json['divisionThree'] ?? '',
      divisionThreeLabel: '',
      place: json['place'] ?? '',
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
    );
  }
}

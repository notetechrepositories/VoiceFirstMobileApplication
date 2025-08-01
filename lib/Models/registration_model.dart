// class RegistrationData {
//   final String firstName;
//   final String? lastName;
//   final String addressOne;
//   final String? addressTwo;
//   final String mobile;
//   final String zipCode;
//   final String email;
//   final int birthYear;
//   final String gender;
//   final String countryId;
//   final String divisionOneId;
//   final String divisionTwoId;
//   final String divisionThreeId;
//   final String place;
//   final String password;
//   final String confirmPassword;

//   RegistrationData({
//     required this.firstName,
//     this.lastName,
//     required this.addressOne,
//     this.addressTwo,
//     required this.mobile,
//     required this.zipCode,
//     required this.email,
//     required this.birthYear,
//     required this.gender,
//     required this.countryId,
//     required this.divisionOneId,
//     required this.divisionTwoId,
//     required this.divisionThreeId,
//     required this.place,
//     required this.password,
//     required this.confirmPassword,
//   });

//   RegistrationData copyWith({
//     String? firstName,
//     String? lastName,
//     String? addressOne,
//     String? addressTwo,
//     String? mobile,
//     String? zipCode,
//     String? email,
//     int? birthYear,
//     String? gender,
//     String? countryId,
//     String? divisionOneId,
//     String? divisionTwoId,
//     String? divisionThreeId,
//     String? place,
//     String? password,
//     String? confirmPassword,
//   }) {
//     return RegistrationData(
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       addressOne: addressOne ?? this.addressOne,
//       addressTwo: addressTwo ?? this.addressTwo,
//       mobile: mobile ?? this.mobile,
//       zipCode: zipCode ?? this.zipCode,
//       email: email ?? this.email,
//       birthYear: birthYear ?? this.birthYear,
//       gender: gender ?? this.gender,
//       countryId: countryId ?? this.countryId,
//       divisionOneId: divisionOneId ?? this.divisionOneId,
//       divisionTwoId: divisionTwoId ?? this.divisionTwoId,
//       divisionThreeId: divisionThreeId ?? this.divisionThreeId,
//       place: place ?? this.place,
//       password: password ?? this.password,
//       confirmPassword: confirmPassword ?? this.confirmPassword,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'firstName': firstName,
//       'lastName': lastName ?? '',
//       'addressOne': addressOne,
//       'addressTwo': addressTwo ?? '',
//       'mobile': mobile,
//       'zipCode': zipCode,
//       'email': email,
//       'birthYear': birthYear,
//       'gender': gender,
//       'country': countryId,
//       'divisionOne': divisionOneId,
//       'divisionTwo': divisionTwoId,
//       'divisionThree': divisionThreeId,
//       'place': place,
//       'password': password,
//       'confirmPassword': confirmPassword,
//     };
//   }

//   factory RegistrationData.fromJson(Map<String, dynamic> json) {
//     return RegistrationData(
//       firstName: json['firstName'],
//       lastName: json['lastName'],
//       addressOne: json['addressOne'],
//       addressTwo: json['addressTwo'],
//       mobile: json['mobile'],
//       zipCode: json['zipCode'],
//       email: json['email'],
//       birthYear: json['birthYear'],
//       gender: json['gender'],
//       countryId: json['country'],
//       divisionOneId: json['divisionOne'],
//       divisionThreeId: json['divisionTwo'],
//       divisionTwoId: json['divisionThree'],
//       place: json['place'],
//       password: json['password'],
//       confirmPassword: json['confirmPassword'],
//     );
//   }
// }
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
      firstName: json['firstName'],
      lastName: json['lastName'],
      addressOne: json['addressOne'],
      addressTwo: json['addressTwo'],
      mobile: json['mobile'],
      zipCode: json['zipCode'],
      email: json['email'],
      birthYear: json['birthYear'],
      gender: json['gender'],
      countryId: json['country'], // assuming you store ID from API
      countryLabel: '', // fill manually if needed
      divisionOneId: json['divisionOne'],
      divisionOneLabel: '',
      divisionTwoId: json['divisionTwo'],
      divisionTwoLabel: '',
      divisionThreeId: json['divisionThree'],
      divisionThreeLabel: '',
      place: json['place'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
    );
  }
}

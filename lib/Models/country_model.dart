class CountryModel {
  final String id;
  final String country;
  final String countryCode;
  final String? divisionOneLabel;
  final String? divisionTwoLabel;
  final String? divisionThreeLabel;
  bool status;

  CountryModel({
    required this.id,
    required this.country,
    required this.countryCode,
    this.divisionOneLabel,
    this.divisionTwoLabel,
    this.divisionThreeLabel,
    required this.status,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      country: json['country'],
      countryCode: json['countryCode'],
      divisionOneLabel: json['divisionOneLabel'],
      divisionTwoLabel: json['divisionTwoLabel'],
      divisionThreeLabel: json['divisionThreeLabel'],
      status: json['status'],
    );
  }
}

class CountryModel {
  final String id;
  final String country;
  final String countryCode;
  final String? divisionOneLabel;
  final String? divisionTwoLabel;
  final String? divisionThreeLabel;
  bool? status;

  CountryModel({
    required this.id,
    required this.country,
    required this.countryCode,
    this.divisionOneLabel,
    this.divisionTwoLabel,
    this.divisionThreeLabel,
    this.status,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

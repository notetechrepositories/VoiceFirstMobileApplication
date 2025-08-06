class DivisionOneModel {
  final String id;
  final String divisionOne;
  final String countryId;
  bool status;
  final String? divisionTwoLabel;

  DivisionOneModel({
    required this.id,
    required this.divisionOne,
    required this.countryId,
    required this.status,
    this.divisionTwoLabel,
  });

  factory DivisionOneModel.fromJson(
    Map<String, dynamic> json, {
    String? divisionTwoLabel,
  }) {
    return DivisionOneModel(
      id: json['id'],
      divisionOne: json['divisionOne'],
      countryId: json['countryId'],
      status: json['status'],
      divisionTwoLabel: divisionTwoLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'divisionOne': divisionOne,
      'countryId': countryId,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionOneModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

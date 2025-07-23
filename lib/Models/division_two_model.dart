class DivisionTwoModel {
  final String id;
  final String divisionOneId;
  final String divisionTwo;
  bool status;
  final String? divisionThreeLabel;

  DivisionTwoModel({
    required this.id,
    required this.divisionOneId,
    required this.divisionTwo,
    required this.status,
    this.divisionThreeLabel,
  });

  // factory DivisionTwoModel.fromJson(Map<String, dynamic> json) {
  //   return DivisionTwoModel(
  //     id: json['id'] as String,
  //     divisionOneId: json['divisionOneId'] as String,
  //     divisionTwo: json['divisionTwo'] as String,
  //     status: json['status'] as bool,
  //     divisionThreeLabel:
  //   );
  // }

  factory DivisionTwoModel.fromJson(
    Map<String, dynamic> json, {
    String? divisionThreeLabel,
  }) {
    return DivisionTwoModel(
      id: json['id'],
      divisionTwo: json['divisionTwo'],
      divisionOneId: json['divisionOneId'],
      status: json['status'],
      divisionThreeLabel: divisionThreeLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'divisionOneId': divisionOneId,
      'divisionTwo': divisionTwo,
      'status': status,
    };
  }
}

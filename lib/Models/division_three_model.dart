class DivisionThreeModel {
  final String id;
  final String divisionTwoId;
  final String divisionThree;
  bool status;

  DivisionThreeModel({
    required this.id,
    required this.divisionTwoId,
    required this.divisionThree,
    required this.status,
  });

  factory DivisionThreeModel.fromJson(Map<String, dynamic> json) {
    return DivisionThreeModel(
      id: json['id'],
      divisionTwoId: json['divisionTwoId'],
      divisionThree: json['divisionThree'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'divisionTwoId': divisionTwoId,
      'divisionThree': divisionThree,
      'status': status,
    };
  }
}

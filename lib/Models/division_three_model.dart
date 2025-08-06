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

   @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionThreeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

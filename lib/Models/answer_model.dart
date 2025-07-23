class AnswerTypeModel {
  String id;
  String name;
  bool status; // now mutable

  AnswerTypeModel({required this.id, required this.name, required this.status});

  factory AnswerTypeModel.fromJson(Map<String, dynamic> json) {
    return AnswerTypeModel(
      id: json['id'],
      name: json['answerTypeName'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'answerTypeName': name, 'status': status};
  }
}

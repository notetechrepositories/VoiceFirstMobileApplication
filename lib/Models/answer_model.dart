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

// models/attachment_type_model.dart
class AttachmentTypeModel {
  final String id;
  final String name;

  AttachmentTypeModel({required this.id, required this.name});

  factory AttachmentTypeModel.fromJson(Map<String, dynamic> json) {
    return AttachmentTypeModel(id: json['id'], name: json['attachmentType']);
  }
}

// models/media_type_model.dart
class MediaTypeModel {
  final String id;
  final String description;

  MediaTypeModel({required this.id, required this.description});

  factory MediaTypeModel.fromJson(Map<String, dynamic> json) {
    return MediaTypeModel(id: json['id'], description: json['description']);
  }
}

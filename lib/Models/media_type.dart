class MediaTypeModel {
  final String id;
  final String description;
  bool status;

  MediaTypeModel({
    required this.id,
    required this.description,
    required this.status,
  });

  // Factory method to create a MediaTypeModel from a JSON map
  factory MediaTypeModel.fromJson(Map<String, dynamic> json) {
    return MediaTypeModel(
      id: json['id'] as String,
      description: json['description'] as String,
      status: json['status'] as bool,
    );
  }

  // Method to convert the object back into a JSON map for requests
  Map<String, dynamic> toJson() {
    return {'id': id, 'description': description, 'status': status};
  }
}

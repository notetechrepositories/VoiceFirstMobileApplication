class CompanyMediaTypeModel {
  final String id;
  final String? mediaTypeId; // Can be null
  final String companyDescription;
  final bool status;

  CompanyMediaTypeModel({
    required this.id,
    this.mediaTypeId,
    required this.companyDescription,
    required this.status,
  });

  // Factory method to convert JSON response into CompanyMediaTypeModel
  factory CompanyMediaTypeModel.fromJson(Map<String, dynamic> json) {
    return CompanyMediaTypeModel(
      id: json['id'] as String,
      mediaTypeId: json['mediaTypeId'] as String?, // Ensure this is nullable
      companyDescription: json['companyDescription'] as String,
      status: json['status'] as bool,
    );
  }

  // Method to convert CompanyMediaTypeModel back to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaTypeId': mediaTypeId,
      'companyDescription': companyDescription,
      'status': status,
    };
  }
}

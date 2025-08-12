class CompanyAnswerTypeModel {
  String id;
  String companyAnswerTypeName; // The name of the answer type for the company
  String? answerTypeId; // This can be nullable, as it is null in some entries
  bool status; // Whether the answer type is active or not

  // Constructor for creating instances of CompanyAnswerTypeModel
  CompanyAnswerTypeModel({
    required this.id,
    required this.companyAnswerTypeName,
    this.answerTypeId,
    required this.status,
  });

  // Factory method to convert JSON into an instance of CompanyAnswerTypeModel
  factory CompanyAnswerTypeModel.fromJson(Map<String, dynamic> json) {
    return CompanyAnswerTypeModel(
      id: json['id'], // Mapping 'id' from the response to 'id' in the model
      companyAnswerTypeName:
          json['companyAnswerTypeName'], // Mapping 'companyAnswerTypeName' from the response
      answerTypeId:
          json['answerTypeId'], // answerTypeId can be null, so it will be handled as nullable
      status: json['status'], // Mapping the status (true/false)
    );
  }

  // Method to convert the model back into JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id, // The id will remain as is
      'companyAnswerTypeName':
          companyAnswerTypeName, // Convert the name to JSON with the proper key
      'answerTypeId': answerTypeId, // answerTypeId might be null
      'status': status, // The status will be a boolean value
    };
  }
}

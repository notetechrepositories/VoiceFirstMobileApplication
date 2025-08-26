class IssueStatusModel {
  String id;
  String issueStatus; // The name of the answer type for the company
  bool status; // Whether the answer type is active or not

  // Constructor for creating instances of IssueStatusModel
  IssueStatusModel({
    required this.id,
    required this.issueStatus,
    required this.status,
  });

  // Factory method to convert JSON into an instance of IssueStatusModel
  factory IssueStatusModel.fromJson(Map<String, dynamic> json) {
    return IssueStatusModel(
      id: json['id'], // Mapping 'id' from the response to 'id' in the model
      issueStatus:
          json['issueStatus'], // Mapping 'companyAnswerTypeName' from the response
      status: json['status'], // Mapping the status (true/false)
    );
  }

  // Method to convert the model back into JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id, // The id will remain as is
      'issueStatus':
          issueStatus, // Convert the name to JSON with the proper key
      'status': status, // The status will be a boolean value
    };
  }
}

class CompanyIssuestatusModel {
  String id;
  String companyIssueStatus; // The name of the answer type for the company
  String? issueStatusId; // This can be nullable, as it is null in some entries
  bool status; // Whether the answer type is active or not

  // Constructor for creating instances of CompanyIssuestatusModel
  CompanyIssuestatusModel({
    required this.id,
    required this.companyIssueStatus,
    this.issueStatusId,
    required this.status,
  });

  // Factory method to convert JSON into an instance of CompanyIssuestatusModel
  factory CompanyIssuestatusModel.fromJson(Map<String, dynamic> json) {
    return CompanyIssuestatusModel(
      id: json['id'], // Mapping 'id' from the response to 'id' in the model
      companyIssueStatus:
          json['companyIssueStatus'], // Mapping 'companyIssueStatus' from the response
      issueStatusId:
          json['issueStatusId'], // issueStatusId can be null, so it will be handled as nullable
      status: json['status'], // Mapping the status (true/false)
    );
  }

  // Method to convert the model back into JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id, // The id will remain as is
      'companyIssueStatus':
          companyIssueStatus, // Convert the name to JSON with the proper key
      'issueStatusId': issueStatusId, // issueStatusId might be null
      'status': status, // The status will be a boolean value
    };
  }
}

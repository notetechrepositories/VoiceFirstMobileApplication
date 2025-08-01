class IssueType {
  final String id;
  final String issueType;
  final bool status;

  IssueType({required this.id, required this.issueType, required this.status});

  factory IssueType.fromJson(Map<String, dynamic> json) {
    return IssueType(
      id: json['id'],
      issueType: json['issueType'],
      status: json['status'],
    );
  }
}

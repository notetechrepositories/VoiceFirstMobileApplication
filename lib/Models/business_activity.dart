class BusinessActivity {
  final String id;
  final String activityName;
  final bool company;
  final bool branch;
  final bool section;
  final bool subSection;
  final bool status;

  BusinessActivity({
    required this.id,
    required this.activityName,
    required this.company,
    required this.branch,
    required this.section,
    required this.subSection,
    required this.status,
  });

  factory BusinessActivity.fromJson(Map<String, dynamic> json) {
    return BusinessActivity(
      id: json['id'],
      activityName: json['activityName'],
      company: json['company'],
      branch: json['branch'],
      section: json['section'],
      subSection: json['subSection'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityName': activityName,
    'company': company,
    'branch': branch,
    'section': section,
    'subSection': subSection,
    'status': status,
  };
}

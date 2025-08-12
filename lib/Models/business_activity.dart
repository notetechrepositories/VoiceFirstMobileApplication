class BusinessActivity {
  final String id;
  final String activityName;
  final bool isForCompany;
  final bool isForBranch;
  // final bool section;
  // final bool subSection;
  final bool status;

  BusinessActivity({
    required this.id,
    required this.activityName,
    required this.isForCompany,
    required this.isForBranch,
    // required this.section,
    // required this.subSection,
    required this.status,
  });

  factory BusinessActivity.fromJson(Map<String, dynamic> json) {
    return BusinessActivity(
      id: json['id'],
      activityName: json['activityName'],
      isForCompany: json['isForCompany'],
      isForBranch: json['isForBranch'],
      // section: json['section'],
      // subSection: json['subSection'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityName': activityName,
    'isForCompany': isForCompany,
    'isForBranch': isForBranch,
    // 'section': section,
    // 'subSection': subSection,
    'status': status,
  };
}

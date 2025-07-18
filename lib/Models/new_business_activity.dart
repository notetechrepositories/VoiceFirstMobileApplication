class NewBusinessActivity {
  final String activityName;
  final bool company;
  final bool branch;
  final bool section;
  final bool subSection;

  NewBusinessActivity({
    required this.activityName,
    required this.company,
    required this.branch,
    required this.section,
    required this.subSection,
  });

  Map<String, dynamic> toJson() => {
    'activityName': activityName,
    'company': company,
    'branch': branch,
    'section': section,
    'subSection': subSection,
  };
}

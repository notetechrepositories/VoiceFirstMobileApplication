class BusinessActivity {
  final String id;
  final String activityName;
  final bool isForCompany;
  final bool isForBranch;
  final bool status;

  BusinessActivity({
    required this.id,
    required this.activityName,
    required this.isForCompany,
    required this.isForBranch,
    required this.status,
  });


  // factory BusinessActivity.fromJson(Map<String, dynamic> json) {
  //   return BusinessActivity(
  //     id: json['id'],
  //     activityName: json['activityName'],
  //     isForCompany: json['isForCompany'],
  //     isForBranch: json['isForBranch'],
  //     status: json['status'],
  //   );
  // }


  factory BusinessActivity.fromJson(Map<String, dynamic> json) {
    return BusinessActivity(
      id: json['id']?.toString() ?? '',
      activityName: json['activityName'] ?? '',
      isForCompany: json['isForCompany'] == true,
      isForBranch: json['isForBranch'] == true,
      status: json['status'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityName': activityName,
    'isForCompany': isForCompany,
    'isForBranch': isForBranch,
    'status': status,
  };

  // the below all is for dio
  BusinessActivity copyWith({
    String? activityName,
    bool? isForCompany,
    bool? isForBranch,
    bool? status,
  }) {
    return BusinessActivity(
      id: id,
      activityName: activityName ?? this.activityName,
      isForCompany: isForCompany ?? this.isForCompany,
      isForBranch: isForBranch ?? this.isForBranch,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> patchFrom(BusinessActivity before) {
    final m = <String, dynamic>{'id': id};
    if (activityName != before.activityName) m['activityName'] = activityName;
    if (isForCompany != before.isForCompany) m['isForCompany'] = isForCompany;
    if (isForBranch != before.isForBranch) m['isForBranch'] = isForBranch;
    if (status != before.status) m['status'] = status;
    return m;
  }
}

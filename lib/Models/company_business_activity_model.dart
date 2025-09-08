class CompanyBusinessActivityModel {
  final String id;
  final String activityName;
  final bool status;

  CompanyBusinessActivityModel({
    required this.id,
    required this.activityName,
    required this.status,
  });

  factory CompanyBusinessActivityModel.fromJson(Map<String, dynamic> json) {
    return CompanyBusinessActivityModel(
      id: json['id']?.toString() ?? '',
      activityName: json['activityName']?.toString() ?? '',
      status: json['status'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'activityName': activityName, 'status': status};
  }

  CompanyBusinessActivityModel copyWith({
    String? id,
    String? activityName,
    bool? status,
  }) {
    return CompanyBusinessActivityModel(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      status: status ?? this.status,
    );
  }
}


class CompanyBusinessActivityResponse {
  final bool isSuccess;
  final String message;
  final String? errorType;
  final List<CompanyBusinessActivityModel> data;

  CompanyBusinessActivityResponse({
    required this.isSuccess,
    required this.message,
    this.errorType,
    required this.data,
  });

  factory CompanyBusinessActivityResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : const [];
    return CompanyBusinessActivityResponse(
      isSuccess: json['isSuccess'] == true,
      message: json['message']?.toString() ?? '',
      errorType: json['errorType']?.toString(),
      data: list.map((e) =>
        CompanyBusinessActivityModel.fromJson((e as Map).cast<String, dynamic>())
      ).toList(),
    );
  }
}

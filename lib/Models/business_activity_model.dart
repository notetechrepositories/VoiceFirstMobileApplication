import 'package:voicefirst/Models/business_activity_model1.dart';

class BusinessActivityModel {
  final bool isSuccess;
  final String message;
  final String? errorType;
  final List<BusinessActivity> data;

  BusinessActivityModel({
    required this.isSuccess,
    required this.message,
    required this.errorType,
    required this.data,
  });

  // factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
  //   return BusinessActivityModel(
  //     isSuccess: json['isSuccess'],
  //     message: json['message'],
  //     errorType: json['errorType'],
  //     data: List<BusinessActivity>.from(
  //       json['data'].map((x) => BusinessActivity.fromJson(x)),
  //     ),
  //   );
  // }

  factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : const [];
    return BusinessActivityModel(
      isSuccess: json['isSuccess'] == true,
      message: json['message']?.toString() ?? '',
      errorType: json['errorType']?.toString(),
      data: list
          .map(
            (e) =>
                BusinessActivity.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'message': message,
    'errorType': errorType,
    'data': data.map((x) => x.toJson()).toList(),
  };
}

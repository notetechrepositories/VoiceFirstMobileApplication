// class Activity {
//   final String id;
//   final String businessActivityName;
//   final String company;
//   final String branch;
//   final String section;
//   final String subSection;

//   // Constructor to initialize the fields
//   Activity({
//     required this.id,
//     required this.businessActivityName,
//     required this.company,
//     required this.branch,
//     required this.section,
//     required this.subSection,
//   });

//   // Factory method to create an Activity instance from a map (for parsing JSON)
//   factory Activity.fromJson(Map<String, dynamic> json) {
//     return Activity(
//       id: json['id'],
//       businessActivityName: json['business_activity_name'],
//       company: json['company'],
//       branch: json['branch'],
//       section: json['section'],
//       subSection: json['sub_section'],
//     );
//   }

//   // Method to convert the Activity instance back to a map (for serializing to JSON)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'business_activity_name': businessActivityName,
//       'company': company,
//       'branch': branch,
//       'section': section,
//       'sub_section': subSection,
//     };
//   }
// }

import 'package:voicefirst/Models/business_activity.dart';

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

  factory BusinessActivityModel.fromJson(Map<String, dynamic> json) {
    return BusinessActivityModel(
      isSuccess: json['isSuccess'],
      message: json['message'],
      errorType: json['errorType'],
      data: List<BusinessActivity>.from(
        json['data'].map((x) => BusinessActivity.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'message': message,
    'errorType': errorType,
    'data': data.map((x) => x.toJson()).toList(),
  };
}

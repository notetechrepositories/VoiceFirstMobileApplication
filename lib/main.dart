import 'package:flutter/material.dart';
import 'package:voicefirst/Views/AdminSide/IssueStatus/issue_status.dart';
import 'package:voicefirst/Views/CompanySide/AnswerType/company_answer_type.dart';
import 'package:voicefirst/Views/CompanySide/BusinessActivity/business_activity_comp.dart';
import 'package:voicefirst/Views/CompanySide/CompanyIssueStatus/company_issue_status.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_view.dart';
import 'package:voicefirst/Views/AdminSide/IssueType/issue_type.dart';
import 'package:voicefirst/Views/AdminSide/Roles/role_screen.dart';
import 'package:voicefirst/Views/Splash/splash_screen.dart';
import 'Views/AdminSide/AnswerType/answer_type.dart';
import 'Views/AdminSide/BusinessActivty/admin_business_activity.dart';
import 'Views/AdminSide/MediaType/add_media_type.dart';
import 'Views/CompanySide/MediaType/media_type.dart';
import 'Views/Dashboard/user_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.white60),
          labelStyle: TextStyle(color: Colors.white),
        ),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: SnackbarHelper.navigatorKey,
      home: SplashScreen(),

      routes: {
        'system-roles': (context) => RoleListScreen(),
        "system-business-activity": (context) => AddBusinessactivity(),
        "business-activity": (context) => AddBusiness(),
        "/admin/admin-dashboard": (context) => Userhomescreen(),
        "country": (context) => CountryView(),
        "system-answer-type": (context) => ManageAnswerTypePage(),
        "system-issue-type": (context) => ManageIssueTypeScreen(),
        "answer-type": (context) => CompanyAnswerType(),
        "system-media-type": (context) => ManageMediaTypePage(),
        "system-issue-status": (context) => IssueStatus(),
        "issue-status": (context) => CompanyIssueStatus(),
        "media-type": (context) => ManageCompanyMediaTypePage(),
      },
    );
  }
}

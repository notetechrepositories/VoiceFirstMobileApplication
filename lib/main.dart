import 'package:flutter/material.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_view.dart';
import 'package:voicefirst/Views/IssueType/issue_type.dart';
import 'package:voicefirst/Views/Roles/role_screen.dart';
import 'package:voicefirst/Views/Splash/splash_screen.dart';
import 'Views/AdminSide/BusinessActivty/business_activity.dart';
import 'Views/AnswerType/answer_type.dart';
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
        "/admin/admin-dashboard": (context) => Userhomescreen(),
        "country": (context) => CountryView(),
        "system-answer-type": (context) => ManageAnswerTypePage(),
        "issue-type": (context) => ManageIssueTypeScreen(),
      },
    );
  }
}

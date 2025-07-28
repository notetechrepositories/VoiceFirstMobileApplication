import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Constants/snack_bar.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_view.dart';
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
      debugShowCheckedModeBanner: false,
      navigatorKey: SnackbarHelper.navigatorKey,
      home: SplashScreen(),
      routes: {
        'system-roles': (context) => RoleListScreen(),
        "system-business-activity": (context) => AddBusinessactivity(),
        "/admin/admin-dashboard": (context) => Userhomescreen(),
        "country": (context) => CountryView(),
        "system-answer-type": (context) => ManageAnswerTypePage(),
      },
    );
  }
}

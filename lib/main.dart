import 'package:flutter/material.dart';
import 'package:voicefirst/Views/Roles/role_screen.dart';
import 'package:voicefirst/Views/Splash/splash_screen.dart';

import 'Views/AdminSide/BusinessActivty/business_activity.dart';
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
      home: SplashScreen(),
      routes: {
        '/admin/system-roles': (context) => RoleListScreen(),
        "/admin/business-activity": (context) => AddBusinessactivity(),
        "/admin/admin-dashboard": (context) => Userhomescreen(),
      },
    );
  }
}

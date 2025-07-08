import 'package:flutter/material.dart';
import 'package:voicefirst/Views/Dashboard/user_home_screen.dart';
import 'package:voicefirst/Views/Profile/profile.dart';
import 'package:voicefirst/Views/QRPage/oq_scanner.dart';
import 'package:voicefirst/Views/SavedPage/saved_page.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  _BottomnavbarState createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    Userhomescreen(),
    SavedScreen(),
    QrScanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFFFCC737),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(color: Color(0xFFFCC737)),
        unselectedLabelStyle: TextStyle(color: Colors.white),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

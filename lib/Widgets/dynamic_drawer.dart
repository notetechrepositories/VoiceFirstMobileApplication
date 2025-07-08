import 'package:flutter/material.dart';
import 'package:voicefirst/Models/menu_item_model.dart';

class CustomDrawer extends StatelessWidget {
  final List<MenuItem> items;

  Map<String, IconData> iconMap = {
    'dashboard': Icons.dashboard,
    'settings': Icons.settings,
    'lock': Icons.lock,
    'file-search': Icons.search,
    'bar-chart': Icons.bar_chart,
    'line-chart': Icons.show_chart,
    'mail': Icons.mail,
    'message-circle': Icons.message,
    'help-circle': Icons.help,
    'calendar': Icons.calendar_today,
    'folder': Icons.folder,
    'clock': Icons.access_time,
    'check-circle': Icons.check_circle,
    'archive': Icons.archive,
    'book-open': Icons.book,
    'compass': Icons.explore,
    'company': Icons.business,
    'Users': Icons.person,
    'branch': Icons.location_city,
    'section': Icons.view_list,
    'sub section': Icons.category,
    'product': Icons.shopping_bag,
    'subscription': Icons.subscriptions,
    'sys entry': Icons.settings_applications,
    'issue type': Icons.warning,
    'activity type': Icons.timeline,
    'roles': Icons.admin_panel_settings,
    'issue define': Icons.assignment,
  };
  IconData _mapIcon(String iconName) {
    return iconMap[iconName.trim().toLowerCase()] ?? Icons.menu;
  }

  CustomDrawer({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Custom Header to match SplashScreen
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                children: [
                  // Logo Image (same as splash1.png)
                  Image.asset(
                    'assets/SplashScreenImage/splash1.png',
                    height: 80,
                  ),
                  const SizedBox(height: 12),
                  // App Name Image (same as splash2.png)
                  Image.asset(
                    'assets/SplashScreenImage/splash2.png',
                    height: 30,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const Divider(color: Colors.white24, thickness: 1),
            // Menu List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: items
                    .map((item) => _buildTile(item, context))
                    .toList(),
              ),
            ),
            const Divider(color: Colors.white24),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Powered by Notetech Software',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(MenuItem item, BuildContext context) {
    if (item.children.isEmpty) {
      return ListTile(
        leading: Icon(_mapIcon(item.icon), color: const Color(0xFFFCC737)),
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        onTap: () {
          if (item.route != null && item.route!.isNotEmpty) {
            Navigator.pushNamed(context, item.route!);
          }
        },
      );
    } else {
      return Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white54,
          leading: Icon(_mapIcon(item.icon), color: const Color(0xFFFCC737)),
          title: Text(item.name, style: const TextStyle(color: Colors.white)),
          children: item.children
              .map((child) => _buildTile(child, context))
              .toList(),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';

class CustomDrawer extends StatelessWidget {
  final List<MenuItem> items;

  CustomDrawer({super.key, required this.items});

  final Map<String, IconData> iconMap = {
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
    'users': Icons.person,
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

  IconData _mapIcon(String? iconName) {
    final key = (iconName ?? '').trim().toLowerCase();
    return iconMap[key] ?? Icons.menu;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                children: [
                  Image.asset(
                    'assets/SplashScreenImage/splash1.png',
                    height: 80,
                  ),
                  const SizedBox(height: 12),
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

            Divider(color: Colors.white24),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFCC737)),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop(); // close drawer
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
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
    final hasValidRoute = item.route != null && item.route!.trim().isNotEmpty;

    if (item.children.isEmpty) {
      return ListTile(
        leading: Icon(_mapIcon(item.icon), color: const Color(0xFFFCC737)),
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        onTap: () {
          if (hasValidRoute) {
            Navigator.pushNamed(context, item.route!.trim());
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

import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Privacy & Security',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildOptionTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // Navigate to Change Password Page
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.phonelink_lock,
            title: 'Two-Factor Authentication',
            onTap: () {
              // Navigate to 2FA Settings
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.security,
            title: 'App Permissions',
            onTap: () {
              // Navigate to Permissions Page
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.block,
            title: 'Blocked Users',
            onTap: () {
              // Navigate to Blocked Users Page
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.description_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Open Privacy Policy Page or WebView
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }
}

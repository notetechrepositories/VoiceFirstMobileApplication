import 'package:flutter/material.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';
import 'package:voicefirst/Views/Profile/account_settings.dart';
import 'package:voicefirst/Views/Profile/help_support.dart';
import 'package:voicefirst/Views/Profile/privacy_settings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 24),
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
          SizedBox(height: 12),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('johndoe@example.com', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 20),
          // Edit Profile Button
          ElevatedButton(
            onPressed: () {
              // Navigate to Edit Profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFCC737),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Edit'),
          ),
          SizedBox(height: 30),
          Divider(color: Colors.grey[700]),
          // Options
          _buildProfileOption(
            Icons.lock,
            'Account Settings',
            onTap: () {
              print('Navigating to Accountsettings');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Accountsettings()),
              );
            },
          ),

          _buildProfileOption(
            Icons.security,
            'Privacy & Security',
            onTap: () {
              print('Navigating to PrivacySecurityPage');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySecurityPage()),
              );
            },
          ),
          _buildProfileOption(
            Icons.help_outline,
            'Help and Supports',
            onTap: () {
              print('Navigating to PrivacySecurityPage');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportPage()),
              );
            },
          ),

          _buildProfileOption(
            Icons.logout,
            'Log Out',
            color: Colors.redAccent,
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white, fontSize: 16),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: color ?? Colors.white,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}

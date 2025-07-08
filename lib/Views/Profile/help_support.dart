import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Help & Support', style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSupportOption(
            icon: Icons.question_answer,
            title: 'FAQs',
            onTap: () {
              // Navigate to FAQ Page
            },
          ),
          _buildSupportOption(
            icon: Icons.mail_outline,
            title: 'Contact Support',
            onTap: () {
              // Navigate to contact form or open email
            },
          ),
          _buildSupportOption(
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            onTap: () {
              // Navigate to problem report form
            },
          ),
          _buildSupportOption(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            onTap: () {
              // Navigate to chat or show a message
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }
}

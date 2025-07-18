// import 'package:flutter/material.dart';

// class AddActivityPage extends StatefulWidget {
//   final Function(Map<String, dynamic>) onActivityAdded;

//   const AddActivityPage({super.key, required this.onActivityAdded});

//   @override
//   State<AddActivityPage> createState() => _AddActivityPageState();
// }

// class _AddActivityPageState extends State<AddActivityPage> {
//   final TextEditingController _nameController = TextEditingController();
//   bool _company = false;
//   bool _branch = false;
//   bool _section = false;
//   bool _subSection = false;

//   final Color _bgColor = Colors.black;
//   final Color _accentColor = Color(0xFFFCC737);
//   final Color _textPrimary = Colors.white;
//   final Color _textSecondary = Colors.white60;
//   final Color _cardColor = Color(0xFF262626);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgColor,
//       appBar: AppBar(
//         backgroundColor: _bgColor,
//         iconTheme: IconThemeData(color: _accentColor),
//         elevation: 0,
//         title: Text(
//           'Add New Activity',
//           style: TextStyle(color: _textSecondary),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Activity name field
//             TextField(
//               controller: _nameController,
//               style: TextStyle(color: _textPrimary),
//               decoration: InputDecoration(
//                 labelText: 'Activity Name',
//                 labelStyle: TextStyle(color: _textSecondary),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Checkboxes
//             CheckboxListTile(
//               value: _company,
//               onChanged: (v) => setState(() => _company = v!),
//               title: Text('Company', style: TextStyle(color: _textPrimary)),
//               controlAffinity: ListTileControlAffinity.leading,
//             ),
//             CheckboxListTile(
//               value: _branch,
//               onChanged: (v) => setState(() => _branch = v!),
//               title: Text('Branch', style: TextStyle(color: _textPrimary)),
//               controlAffinity: ListTileControlAffinity.leading,
//             ),
//             CheckboxListTile(
//               value: _section,
//               onChanged: (v) => setState(() => _section = v!),
//               title: Text('Section', style: TextStyle(color: _textPrimary)),
//               controlAffinity: ListTileControlAffinity.leading,
//             ),
//             CheckboxListTile(
//               value: _subSection,
//               onChanged: (v) => setState(() => _subSection = v!),
//               title: Text('Sub-section', style: TextStyle(color: _textPrimary)),
//               controlAffinity: ListTileControlAffinity.leading,
//             ),

//             // Add button
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 final newActivity = {
//                   'id': DateTime.now().millisecondsSinceEpoch.toString(),
//                   'business_activity_name': _nameController.text.trim(),
//                   'company': _company ? 'y' : 'n',
//                   'branch': _branch ? 'y' : 'n',
//                   'section': _section ? 'y' : 'n',
//                   'sub_section': _subSection ? 'y' : 'n',
//                 };
//                 widget.onActivityAdded(newActivity);
//                 Navigator.pop(context); // Go back to the previous screen
//               },
//               child: Text('Add Activity'),
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(_accentColor),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AddActivityPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onActivitiesAdded;

  const AddActivityPage({super.key, required this.onActivitiesAdded});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _company = false;
  bool _branch = false;
  bool _section = false;
  bool _subSection = false;

  final Color _bgColor = Colors.black;
  final Color _accentColor = Color(0xFFFCC737);
  final Color _textPrimary = Colors.white;
  final Color _textSecondary = Colors.white60;
  final Color _cardColor = Color(0xFF262626);

  List<Map<String, dynamic>> _newActivities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        iconTheme: IconThemeData(color: _accentColor),
        elevation: 0,
        title: Text(
          'Add New Activity',
          style: TextStyle(color: _textSecondary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Activity name field
            TextField(
              controller: _nameController,
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                labelStyle: TextStyle(color: _textSecondary),
              ),
            ),
            SizedBox(height: 16),

            // Checkboxes for activity types
            CheckboxListTile(
              value: _company,
              onChanged: (v) => setState(() => _company = v!),
              title: Text('Company', style: TextStyle(color: _textPrimary)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _branch,
              onChanged: (v) => setState(() => _branch = v!),
              title: Text('Branch', style: TextStyle(color: _textPrimary)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _section,
              onChanged: (v) => setState(() => _section = v!),
              title: Text('Section', style: TextStyle(color: _textPrimary)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _subSection,
              onChanged: (v) => setState(() => _subSection = v!),
              title: Text('Sub-section', style: TextStyle(color: _textPrimary)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 16),

            // Add More button to add new activity to the list
            ElevatedButton(
              onPressed: () {
                final newActivity = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'business_activity_name': _nameController.text.trim(),
                  'company': _company ? 'y' : 'n',
                  'branch': _branch ? 'y' : 'n',
                  'section': _section ? 'y' : 'n',
                  'sub_section': _subSection ? 'y' : 'n',
                };
                setState(() {
                  _newActivities.add(newActivity);
                });
                _nameController.clear();
                setState(() {
                  _company = false;
                  _branch = false;
                  _section = false;
                  _subSection = false;
                });
              },
              child: Text('Add More'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(_accentColor),
              ),
            ),
            SizedBox(height: 16),

            // Display the added activities
            Expanded(
              child: ListView.builder(
                itemCount: _newActivities.length,
                itemBuilder: (context, index) {
                  final activity = _newActivities[index];
                  return Card(
                    color: _cardColor,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        activity['business_activity_name'],
                        style: TextStyle(color: _textPrimary),
                      ),
                      subtitle: Text(
                        'Company: ${activity['company']}',
                        style: TextStyle(color: _textSecondary),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Submit All button
            ElevatedButton(
              onPressed: () {
                widget.onActivitiesAdded(
                  _newActivities,
                ); // Pass the new activities back to the AddBusiness page
                Navigator.pop(context); // Close the AddActivityPage
              },
              child: Text('Submit All'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(_accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class AddActivityPage extends StatefulWidget {
//   final Function(List<Map<String, dynamic>>) onActivitiesAdded;

//   const AddActivityPage({super.key, required this.onActivitiesAdded});

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

//   List<Map<String, dynamic>> _newActivities = [];

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

//             // Checkboxes for activity types
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
//             SizedBox(height: 16),

//             // Add More button to add new activity to the list
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
//                 setState(() {
//                   _newActivities.add(newActivity);
//                 });
//                 _nameController.clear();
//                 setState(() {
//                   _company = false;
//                   _branch = false;
//                   _section = false;
//                   _subSection = false;
//                 });
//               },
//               child: Text('Add More'),
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(_accentColor),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Display the added activities
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _newActivities.length,
//                 itemBuilder: (context, index) {
//                   final activity = _newActivities[index];
//                   return Card(
//                     color: _cardColor,
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         activity['business_activity_name'],
//                         style: TextStyle(color: _textPrimary),
//                       ),
//                       subtitle: Text(
//                         'Company: ${activity['company']}',
//                         style: TextStyle(color: _textSecondary),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Submit All button
//             ElevatedButton(
//               onPressed: () {
//                 widget.onActivitiesAdded(
//                   _newActivities,
//                 ); // Pass the new activities back to the AddBusiness page
//                 Navigator.pop(context); // Close the AddActivityPage
//               },
//               child: Text('Submit All'),
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

class AddBusinessActivityDialogCompany extends StatefulWidget {
  //for single add
  final Function({
    required String name,
    required bool company,
    required bool branch,
    required bool section,
    required bool subSection,
  })
  onSubmit;

  const AddBusinessActivityDialogCompany({super.key, required this.onSubmit});

  @override
  State<AddBusinessActivityDialogCompany> createState() =>
      _AddBusinessActivityDialogCompanyState();
}

class _AddBusinessActivityDialogCompanyState
    extends State<AddBusinessActivityDialogCompany> {
  final TextEditingController _nameController = TextEditingController();
  bool _company = false;
  bool _branch = false;
  bool _section = false;
  bool _subSection = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF262626),
      title: Text('Add Activity', style: TextStyle(color: Color(0xFFFCC737))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckbox(
              'Company',
              _company,
              (v) => setState(() => _company = v),
            ),
            _buildCheckbox(
              'Branch',
              _branch,
              (v) => setState(() => _branch = v),
            ),
            _buildCheckbox(
              'Section',
              _section,
              (v) => setState(() => _section = v),
            ),
            _buildCheckbox(
              'Sub-section',
              _subSection,
              (v) => setState(() => _subSection = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            widget.onSubmit(
              name: _nameController.text.trim(),
              company: _company,
              branch: _branch,
              section: _section,
              subSection: _subSection,
            );
            Navigator.of(context).pop();
          },
          child: Text('Add', style: TextStyle(color: Color(0xFFFCC737))),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v!),
      title: Text(label, style: TextStyle(color: Colors.white)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

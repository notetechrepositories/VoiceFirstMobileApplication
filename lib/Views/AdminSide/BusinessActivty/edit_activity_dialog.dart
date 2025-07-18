// import 'package:flutter/material.dart';

// class EditActivityDialog extends StatelessWidget {
//   const EditActivityDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// void _showEditDialog(BuildContext ctx, Map<String, dynamic> activity) {
//   // Prefill the controllers & flags
//   _newNameController.text = activity['business_activity_name'];
//   _newCompany = activity['company'] == 'y';
//   _newBranch = activity['branch'] == 'y';
//   _newSection = activity['section'] == 'y';
//   _newSubSection = activity['sub_section'] == 'y';

//   showDialog(
//     context: ctx,
//     builder: (_) => StatefulBuilder(
//       builder: (context, setState) => AlertDialog(
//         backgroundColor: _cardColor,
//         title: Text('Edit Activity', style: TextStyle(color: _accentColor)),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Name field
//               TextField(
//                 controller: _newNameController,
//                 style: TextStyle(color: _textPrimary),
//                 decoration: InputDecoration(
//                   labelText: 'Activity Name',
//                   labelStyle: TextStyle(color: _textSecondary),
//                 ),
//               ),
//               SizedBox(height: 16),

//               // Checkboxes
//               CheckboxListTile(
//                 value: _newCompany,
//                 onChanged: (v) => setState(() => _newCompany = v!),
//                 title: Text('Company', style: TextStyle(color: Colors.white)),
//                 controlAffinity: ListTileControlAffinity.leading,
//               ),
//               CheckboxListTile(
//                 value: _newBranch,
//                 onChanged: (v) => setState(() => _newBranch = v!),
//                 title: Text('Branch', style: TextStyle(color: _textSecondary)),
//                 controlAffinity: ListTileControlAffinity.leading,
//               ),
//               CheckboxListTile(
//                 value: _newSection,
//                 onChanged: (v) => setState(() => _newSection = v!),
//                 title: Text('Section', style: TextStyle(color: _textSecondary)),
//                 controlAffinity: ListTileControlAffinity.leading,
//               ),
//               CheckboxListTile(
//                 value: _newSubSection,
//                 onChanged: (v) => setState(() => _newSubSection = v!),
//                 title: Text(
//                   'Sub-section',
//                   style: TextStyle(color: _textSecondary),
//                 ),
//                 controlAffinity: ListTileControlAffinity.leading,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: Text('Cancel', style: TextStyle(color: _textSecondary)),
//           ),

//           TextButton(
//             onPressed: () async {
//               final newName = _newNameController.text.trim();
//               if (newName.isEmpty) return;

//               final updatedData = {"id": activity['id']};

//               if (activity['business_activity_name'] != newName) {
//                 updatedData['activityName'] = newName;
//               }
//               if ((_newCompany ? 'y' : 'n') != activity['company']) {
//                 updatedData['company'] = _newCompany;
//               }
//               if ((_newBranch ? 'y' : 'n') != activity['branch']) {
//                 updatedData['branch'] = _newBranch;
//               }
//               if ((_newSection ? 'y' : 'n') != activity['section']) {
//                 updatedData['section'] = _newSection;
//               }
//               if ((_newSubSection ? 'y' : 'n') != activity['sub_section']) {
//                 updatedData['subSection'] = _newSubSection;
//               }

//               if (updatedData.length == 1) {
//                 Navigator.of(ctx).pop();
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(SnackBar(content: Text('No changes to update')));
//                 return;
//               }

//               final updatedActivity = await _updateActivityOnServer(
//                 updatedData,
//               );

//               if (updatedActivity != null) {
//                 setState(() {
//                   activity['business_activity_name'] =
//                       updatedActivity['activityName'];
//                   activity['company'] = updatedActivity['company'] ? 'y' : 'n';
//                   activity['branch'] = updatedActivity['branch'] ? 'y' : 'n';
//                   activity['section'] = updatedActivity['section'] ? 'y' : 'n';
//                   activity['sub_section'] = updatedActivity['subSection']
//                       ? 'y'
//                       : 'n';
//                   activity['status'] = updatedActivity['status']
//                       ? 'active'
//                       : 'inactive';
//                   _filterActivities();
//                 });

//                 Navigator.of(ctx).pop();
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(SnackBar(content: Text('Activity updated')));
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to update activity')),
//                 );
//               }
//             },
//             child: Text('Save', style: TextStyle(color: _accentColor)),
//           ),
//         ],
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';

class EditActivityDialog extends StatefulWidget {
  final Map<String, dynamic> activity;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onUpdated;
  final VoidCallback onCancel;

  const EditActivityDialog({
    super.key,
    required this.activity,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.onUpdate,
    required this.onUpdated,
    required this.onCancel,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _nameController;
  late bool _company, _branch, _section, _subSection;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.activity['business_activity_name'],
    );
    _company = widget.activity['company'] == 'y';
    _branch = widget.activity['branch'] == 'y';
    _section = widget.activity['section'] == 'y';
    _subSection = widget.activity['sub_section'] == 'y';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final updatedData = {"id": widget.activity['id']};

    if (widget.activity['business_activity_name'] != newName) {
      updatedData['activityName'] = newName;
    }
    if ((_company ? 'y' : 'n') != widget.activity['company']) {
      updatedData['company'] = _company;
    }
    if ((_branch ? 'y' : 'n') != widget.activity['branch']) {
      updatedData['branch'] = _branch;
    }
    if ((_section ? 'y' : 'n') != widget.activity['section']) {
      updatedData['section'] = _section;
    }
    if ((_subSection ? 'y' : 'n') != widget.activity['sub_section']) {
      updatedData['subSection'] = _subSection;
    }

    if (updatedData.length == 1) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No changes to update')));
      return;
    }

    final updatedActivity = await widget.onUpdate(updatedData);

    if (updatedActivity != null) {
      widget.activity['business_activity_name'] =
          updatedActivity['activityName'];
      widget.activity['company'] = updatedActivity['company'] ? 'y' : 'n';
      widget.activity['branch'] = updatedActivity['branch'] ? 'y' : 'n';
      widget.activity['section'] = updatedActivity['section'] ? 'y' : 'n';
      widget.activity['sub_section'] = updatedActivity['subSection']
          ? 'y'
          : 'n';
      widget.activity['status'] = updatedActivity['status']
          ? 'active'
          : 'inactive';

      widget.onUpdated();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Activity updated')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update activity')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
      title: Text('Edit Activity', style: TextStyle(color: widget.accentColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: widget.textPrimary),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                labelStyle: TextStyle(color: widget.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _company,
              onChanged: (v) => setState(() => _company = v!),
              title: Text(
                'Company',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _branch,
              onChanged: (v) => setState(() => _branch = v!),
              title: Text(
                'Branch',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _section,
              onChanged: (v) => setState(() => _section = v!),
              title: Text(
                'Section',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _subSection,
              onChanged: (v) => setState(() => _subSection = v!),
              title: Text(
                'Sub-section',
                style: TextStyle(color: widget.textPrimary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: Text('Save', style: TextStyle(color: widget.accentColor)),
        ),
      ],
    );
  }
}

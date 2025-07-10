import 'package:flutter/material.dart';
import 'package:voicefirst/Models/menu_item_model.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({super.key});

  @override
  State<AddActivity> createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  final List<Map<String, dynamic>> systemactivities = [
    {
      "id": "010110101",
      "business_activity_name": "jwellary",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110112",
      "business_activity_name": "warehouse",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110013",
      "business_activity_name": "service center",
      "company": "y",
      "branch": "y",
      "section": "n",
      "sub_section": "n",
    },
    {
      "id": "010110104",
      "business_activity_name": "Restaurant",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110115",
      "business_activity_name": "Washroom",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110016",
      "business_activity_name": "HeadOffice",
      "company": "y",
      "branch": "y",
      "section": "n",
      "sub_section": "n",
    },
  ];

  final List<Map<String, dynamic>> activities = [
    {
      "id": "010110104",
      "business_activity_name": "Restaurant",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110115",
      "business_activity_name": "Washroom",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110016",
      "business_activity_name": "HeadOffice",
      "company": "y",
      "branch": "y",
      "section": "n",
      "sub_section": "n",
    },
  ];

  void _filterActivities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredActivities = activities.where((activity) {
        final name = (activity['business_activity_name'] ?? '').toLowerCase();
        // final type =
        return name.contains(query);
      }).toList();
    });
  }

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredActivities = [];
  List<MenuItem> menuItems = [];
  // final TextEditingController _newIdController = TextEditingController();
  final TextEditingController _newNameController = TextEditingController();
  bool _newCompany = false;
  bool _newBranch = false;
  bool _newSection = false;
  bool _newSubSection = false;

  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text

  @override
  Widget build(BuildContext context) {
    void _showAddDialog(BuildContext ctx) {
      showDialog(
        context: ctx,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: _cardColor,
            title: Text('Add Activity', style: TextStyle(color: _accentColor)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //activity name
                  TextField(
                    controller: _newNameController,
                    style: TextStyle(color: _textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Activity Name',
                      labelStyle: TextStyle(color: _textSecondary),
                    ),
                  ),
                  SizedBox(height: 16),

                  // checkboxes
                  CheckboxListTile(
                    value: _newCompany,
                    onChanged: (v) => setState(() => _newCompany = v!),
                    title: Text(
                      'Company',
                      style: TextStyle(color: Colors.white70),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _newBranch,
                    onChanged: (v) => setState(() => _newBranch = v!),
                    title: Text(
                      'Branch',
                      style: TextStyle(color: Colors.white),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _newSection,
                    onChanged: (v) => setState(() => _newSection = v!),
                    title: Text(
                      'Section',
                      style: TextStyle(color: Colors.white),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _newSubSection,
                    onChanged: (v) => setState(() => _newSubSection = v!),
                    title: Text(
                      'Sub-section',
                      style: TextStyle(color: Colors.white),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Cancel', style: TextStyle(color: _textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  final newType = _newNameController.text.trim();
                  if (newType.isEmpty) return;
                  setState(() {
                    final newActivity = {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'business_activity_name': newType,
                      'company': _newCompany ? 'y' : 'n',
                      'branch': _newBranch ? 'y' : 'n',
                      'section': _newSection ? 'y' : 'n',
                      'sub_section': _newSubSection ? 'y' : 'n',
                    };
                    activities.add(newActivity);
                    _filterActivities();
                  });
                  Navigator.of(ctx).pop();
                },
                child: Text('Add', style: TextStyle(color: _accentColor)),
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }
}

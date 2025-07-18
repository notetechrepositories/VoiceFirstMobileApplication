import 'package:flutter/material.dart';

class PageAddBusinessActivity extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onActivitiesAdded;

  const PageAddBusinessActivity({super.key, required this.onActivitiesAdded});

  @override
  State<PageAddBusinessActivity> createState() =>
      _PageAddBusinessActivityState();
}

class _PageAddBusinessActivityState extends State<PageAddBusinessActivity> {
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

  final List<Map<String, dynamic>> _newActivities = [];

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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: _textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Activity Name',
                        labelStyle: TextStyle(color: _textSecondary),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.grey,
                    size: 32.0,
                  ),
                ),
              ],
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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                    // child: Text('add'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(_accentColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Display the added activities
            Expanded(
              child: ListView.builder(
                itemCount: _newActivities.length,
                itemBuilder: (context, index) {
                  final activity = _newActivities[index];
                  final TextEditingController controller =
                      TextEditingController(
                        text: activity['business_activity_name'],
                      );

                  //without editing and simple list view
                  // return Card(
                  //   color: _cardColor,
                  //   margin: EdgeInsets.symmetric(vertical: 8),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: ListTile(
                  //     title: Text(
                  //       activity['business_activity_name'],
                  //       style: TextStyle(color: _textPrimary),
                  //     ),
                  //     subtitle: Text(
                  //       'Company: ${activity['company']}',
                  //       style: TextStyle(color: _textSecondary),
                  //     ),
                  //   ),
                  // );
                  return Card(
                    color: _cardColor,
                    margin: EdgeInsetsGeometry.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //editable activity name
                          TextField(
                            controller: controller,
                            style: TextStyle(color: _textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Activity Name',
                              labelStyle: TextStyle(color: _textSecondary),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _newActivities[index]['business_activity_name'] =
                                  value;
                            },
                          ),
                          SizedBox(height: 12),
                          //checkboxes
                          Wrap(
                            spacing: 10,
                            children: [
                              _buildEditableCheckbox(
                                label: 'Company',
                                value: activity['company'] == 'y',
                                onChanged: (val) {
                                  setState(() {
                                    _newActivities[index]['company'] = val
                                        ? 'y'
                                        : 'n';
                                  });
                                },
                              ),
                              _buildEditableCheckbox(
                                label: 'Branch',
                                value: activity['branch'] == 'y',
                                onChanged: (val) {
                                  setState(() {
                                    _newActivities[index]['branch'] = val
                                        ? 'y'
                                        : 'n';
                                  });
                                },
                              ),
                              _buildEditableCheckbox(
                                label: 'Section',
                                value: activity['section'] == 'y',
                                onChanged: (val) {
                                  setState(() {
                                    _newActivities[index]['section'] = val
                                        ? 'y'
                                        : 'n';
                                  });
                                },
                              ),
                              _buildEditableCheckbox(
                                label: 'Sub-section',
                                value: activity['sub_section'] == 'y',
                                onChanged: (val) {
                                  setState(() {
                                    _newActivities[index]['sub_section'] = val
                                        ? 'y'
                                        : 'n';
                                  });
                                },
                              ),
                            ],
                          ),
                          // Delete button
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _newActivities.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCheckbox({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val!),
          checkColor: _bgColor,
          activeColor: _accentColor,
        ),
        Text(label, style: TextStyle(color: _textPrimary)),
      ],
    );
  }
}

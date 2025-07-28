import 'package:flutter/material.dart';
import 'package:voicefirst/Views/CompanySide/add_activity.dart';
import 'package:voicefirst/Models/menu_item_model.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => AddBusinessState();
}

class AddBusinessState extends State<AddBusiness> {
  List<Map<String, dynamic>> activities = [];

  void _addNewActivities(List<Map<String, dynamic>> newActivities) {
    setState(() {
      activities.addAll(newActivities); // Add all new activities to the list
    });
  }

  // ──────────────────────────────────────
  // Page-specific colour palette
  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text
  // ──────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredActivities = [];
  List<MenuItem> menuItems = [];
  // final TextEditingController _newIdController = TextEditingController();
  final TextEditingController _newNameController = TextEditingController();
  bool _newCompany = false;
  bool _newBranch = false;
  bool _newSection = false;
  bool _newSubSection = false;

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

  @override
  void initState() {
    super.initState();

    filteredActivities = List.from(activities);
    _searchController.addListener(_filterActivities);
    // loadActivities();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // drawer: CustomDrawer(items: menuItems),
      appBar: AppBar(
        backgroundColor: _bgColor,
        iconTheme: IconThemeData(color: _accentColor),
        elevation: 0,
        title: Text(
          'Your Business Activities',
          style: TextStyle(color: _textSecondary),
        ),
      ),
      body: Column(
        children: [
          // ─── Search bar ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: _textSecondary),
                prefixIcon: Icon(Icons.search, color: _textSecondary),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ─── List ────────────────────────────────────
          Expanded(
            child: filteredActivities.isEmpty
                ? Center(
                    child: Text(
                      'No activities found',
                      style: TextStyle(color: _textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (ctx, i) {
                      final a = filteredActivities[i];
                      final labels = <String>[];
                      if (a['company'] == 'y') labels.add('Company');
                      if (a['branch'] == 'y') labels.add('Branch');
                      if (a['section'] == 'y') labels.add('Section');
                      if (a['sub_section'] == 'y') labels.add('Sub-section');

                      return Card(
                        color: _cardColor,
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // ─ Left: just the name ───────────
                              Expanded(
                                child: Text(
                                  a['business_activity_name'] ?? '',
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // ─ Right: eye, edit, delete ─────
                              IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showDetailDialog(context, a),
                              ),

                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    activities.removeWhere(
                                      (x) => x['id'] == a['id'],
                                    );
                                    _filterActivities();
                                  });
                                },
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        child: Icon(Icons.add, color: _bgColor),
        onPressed: () => _showChoiceDialog(context),
      ),
    );
  }

  void _showSelectExistingDialog(BuildContext ctx) {
    // track selections in a local map
    final Map<String, bool> selected = {
      for (var sys in systemactivities) sys['id'] as String: false,
    };

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _cardColor,
          title: Text(
            'Select System Activities',
            style: TextStyle(color: _accentColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: systemactivities.map((sys) {
                final id = sys['id'] as String;
                final name = sys['business_activity_name'] as String;
                final alreadyin = activities.any((a) => a['id'] == id);
                return CheckboxListTile(
                  value: alreadyin || selected[id]!,
                  onChanged: alreadyin
                      ? null
                      : (v) => setState(() => selected[id] = v!),
                  title: Text(name, style: TextStyle(color: _textPrimary)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: _accentColor,
                  // ← NEW: grays out the tile entirely
                  enabled: !alreadyin,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: _textSecondary)),
            ),
            TextButton(
              onPressed: () {
                // add every checked systemactivity into your activities list
                selected.forEach((id, isChecked) {
                  if (!isChecked) return;
                  final sys = systemactivities.firstWhere((s) => s['id'] == id);
                  // avoid duplicates?
                  if (!activities.any((a) => a['id'] == id)) {
                    activities.add(Map<String, dynamic>.from(sys));
                  }
                });
                _filterActivities();
                Navigator.of(ctx).pop();
              },
              child: Text('OK', style: TextStyle(color: _accentColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChoiceDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Add Activity', style: TextStyle(color: _accentColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.list, color: _textPrimary),
              title: Text(
                'Select from existing',
                style: TextStyle(color: _textPrimary),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _showSelectExistingDialog(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.create, color: _textPrimary),
              title: Text(
                'Create your own',
                style: TextStyle(color: _textPrimary),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                AddActivityPage(onActivitiesAdded: _addNewActivities);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext ctx, Map<String, dynamic> activity) {
    final labels = <String>[];
    if (activity['company'] == 'y') labels.add('Company');
    if (activity['branch'] == 'y') labels.add('Branch');
    if (activity['section'] == 'y') labels.add('Section');
    if (activity['sub_section'] == 'y') labels.add('Sub-section');

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Activity Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              'Name: ${activity['business_activity_name'] ?? ''}',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // ID
            // Text(
            //   'ID: ${activity['id']}',
            //   style: TextStyle(color: _textSecondary),
            // ),
            SizedBox(height: 12),

            // Scopes
            Text('Available in:', style: TextStyle(color: _textSecondary)),
            SizedBox(height: 4),
            labels.isEmpty
                ? Text('None', style: TextStyle(color: _textSecondary))
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: labels
                        .map(
                          (lbl) => Chip(
                            label: Text(
                              lbl,
                              style: TextStyle(color: _textPrimary),
                            ),
                            backgroundColor: _chipColor,
                            padding: EdgeInsets.zero,
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.edit_outlined, color: _accentColor),
          //   onPressed: () {
          //     /* your edit logic */
          //   },
          // ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showEditDialog(ctx, activity);
            },
            child: Text('Edit', style: TextStyle(color: _accentColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: _accentColor)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, Map<String, dynamic> activity) {
    // Prefill the controllers & flags
    _newNameController.text = activity['business_activity_name'];
    _newCompany = activity['company'] == 'y';
    _newBranch = activity['branch'] == 'y';
    _newSection = activity['section'] == 'y';
    _newSubSection = activity['sub_section'] == 'y';

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: _cardColor,
          title: Text('Edit Activity', style: TextStyle(color: _accentColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextField(
                  controller: _newNameController,
                  style: TextStyle(color: _textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Activity Name',
                    labelStyle: TextStyle(color: _textSecondary),
                  ),
                ),
                SizedBox(height: 16),

                // Checkboxes
                CheckboxListTile(
                  value: _newCompany,
                  onChanged: (v) => setState(() => _newCompany = v!),
                  title: Text(
                    'Company',
                    style: TextStyle(color: _textSecondary),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _newBranch,
                  onChanged: (v) => setState(() => _newBranch = v!),
                  title: Text(
                    'Branch',
                    style: TextStyle(color: _textSecondary),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _newSection,
                  onChanged: (v) => setState(() => _newSection = v!),
                  title: Text(
                    'Section',
                    style: TextStyle(color: _textSecondary),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _newSubSection,
                  onChanged: (v) => setState(() => _newSubSection = v!),
                  title: Text(
                    'Sub-section',
                    style: TextStyle(color: _textSecondary),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: _textSecondary)),
            ),
            TextButton(
              onPressed: () {
                final newName = _newNameController.text.trim();
                if (newName.isEmpty) return;

                setState(() {
                  activity['business_activity_name'] = newName;
                  activity['company'] = _newCompany ? 'y' : 'n';
                  activity['branch'] = _newBranch ? 'y' : 'n';
                  activity['section'] = _newSection ? 'y' : 'n';
                  activity['sub_section'] = _newSubSection ? 'y' : 'n';
                  _filterActivities();
                });

                Navigator.of(ctx).pop();
              },
              child: Text('Save', style: TextStyle(color: _accentColor)),
            ),
          ],
        ),
      ),
    );
  }

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
                  title: Text('Branch', style: TextStyle(color: Colors.white)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: _newSection,
                  onChanged: (v) => setState(() => _newSection = v!),
                  title: Text('Section', style: TextStyle(color: Colors.white)),
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
}

  // import 'dart:convert';
  // import 'package:flutter/material.dart';
  // import 'package:voicefirst/Views/CompanySide/add_activity.dart';
  // // import 'add_activity_page.dart';  // Import the new AddActivityPage

  // class AddBusiness extends StatefulWidget {
  //   const AddBusiness({super.key});

  //   @override
  //   State<AddBusiness> createState() => _AddBusinessState();
  // }

  // class _AddBusinessState extends State<AddBusiness> {
  //   final Color _bgColor = Colors.black;
  //   final Color _cardColor = Color(0xFF262626);
  //   final Color _chipColor = Color(0xFF212121);
  //   final Color _accentColor = Color(0xFFFCC737);
  //   final Color _textPrimary = Colors.white;
  //   final Color _textSecondary = Colors.white60;

  //   final TextEditingController _searchController = TextEditingController();
  //   List<Map<String, dynamic>> filteredActivities = [];
  //   List<Map<String, dynamic>> activities = [
  //     {
  //       "id": "010110104",
  //       "business_activity_name": "Restaurant",
  //       "company": "y",
  //       "branch": "y",
  //       "section": "y",
  //       "sub_section": "y",
  //     },
  //     {
  //       "id": "010110115",
  //       "business_activity_name": "Washroom",
  //       "company": "y",
  //       "branch": "y",
  //       "section": "y",
  //       "sub_section": "y",
  //     },
  //     {
  //       "id": "010110016",
  //       "business_activity_name": "HeadOffice",
  //       "company": "y",
  //       "branch": "y",
  //       "section": "n",
  //       "sub_section": "n",
  //     },
  //   ];

  //   @override
  //   void initState() {
  //     super.initState();
  //     filteredActivities = List.from(activities);
  //     _searchController.addListener(_filterActivities);
  //   }

  //   void _filterActivities() {
  //     final query = _searchController.text.toLowerCase();
  //     setState(() {
  //       filteredActivities = activities.where((activity) {
  //         final name = (activity['business_activity_name'] ?? '').toLowerCase();
  //         return name.contains(query);
  //       }).toList();
  //     });
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       backgroundColor: _bgColor,
  //       appBar: AppBar(
  //         backgroundColor: _bgColor,
  //         iconTheme: IconThemeData(color: _accentColor),
  //         elevation: 0,
  //         title: Text(
  //           'Your Business Activities',
  //           style: TextStyle(color: _textSecondary),
  //         ),
  //       ),
  //       body: Column(
  //         children: [
  //           // Search bar
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: TextField(
  //               controller: _searchController,
  //               style: TextStyle(color: _textPrimary),
  //               decoration: InputDecoration(
  //                 hintText: 'Search',
  //                 hintStyle: TextStyle(color: _textSecondary),
  //                 prefixIcon: Icon(Icons.search, color: _textSecondary),
  //                 filled: true,
  //                 fillColor: Color(0xFF1E1E1E),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: BorderSide.none,
  //                 ),
  //               ),
  //             ),
  //           ),

  //           // List of activities
  //           Expanded(
  //             child: filteredActivities.isEmpty
  //                 ? Center(
  //                     child: Text(
  //                       'No activities found',
  //                       style: TextStyle(color: _textSecondary),
  //                     ),
  //                   )
  //                 : ListView.builder(
  //                     itemCount: filteredActivities.length,
  //                     itemBuilder: (ctx, i) {
  //                       final a = filteredActivities[i];
  //                       final labels = <String>[];
  //                       if (a['company'] == 'y') labels.add('Company');
  //                       if (a['branch'] == 'y') labels.add('Branch');
  //                       if (a['section'] == 'y') labels.add('Section');
  //                       if (a['sub_section'] == 'y') labels.add('Sub-section');

  //                       return Card(
  //                         color: _cardColor,
  //                         margin: EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 8,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: Padding(
  //                           padding: EdgeInsets.all(12),
  //                           child: Row(
  //                             children: [
  //                               // Left: Activity Name
  //                               Expanded(
  //                                 child: Text(
  //                                   a['business_activity_name'] ?? '',
  //                                   style: TextStyle(
  //                                     color: _textPrimary,
  //                                     fontSize: 16,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                               ),

  //                               // Right: Eye, Edit, Delete
  //                               IconButton(
  //                                 icon: Icon(
  //                                   Icons.remove_red_eye_outlined,
  //                                   color: Colors.white,
  //                                 ),
  //                                 onPressed: () => _showDetailDialog(context, a),
  //                               ),
  //                               IconButton(
  //                                 icon: Icon(
  //                                   Icons.delete_outline,
  //                                   color: Colors.redAccent,
  //                                 ),
  //                                 onPressed: () {
  //                                   setState(() {
  //                                     activities.removeWhere(
  //                                       (x) => x['id'] == a['id'],
  //                                     );
  //                                     _filterActivities();
  //                                   });
  //                                 },
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //           ),
  //         ],
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         backgroundColor: _accentColor,
  //         child: Icon(Icons.add, color: _bgColor),
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => AddActivityPage(
  //                 onActivityAdded: (newActivity) {
  //                   setState(() {
  //                     activities.add(newActivity);
  //                     _filterActivities();
  //                   });
  //                 },
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     );
  //   }

  //   void _showDetailDialog(BuildContext ctx, Map<String, dynamic> activity) {
  //     final labels = <String>[];
  //     if (activity['company'] == 'y') labels.add('Company');
  //     if (activity['branch'] == 'y') labels.add('Branch');
  //     if (activity['section'] == 'y') labels.add('Section');
  //     if (activity['sub_section'] == 'y') labels.add('Sub-section');

  //     showDialog(
  //       context: ctx,
  //       builder: (_) => AlertDialog(
  //         backgroundColor: _cardColor,
  //         title: Text('Activity Details', style: TextStyle(color: Colors.white)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Name
  //             Text(
  //               'Name: ${activity['business_activity_name'] ?? ''}',
  //               style: TextStyle(
  //                 color: _textPrimary,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 8),

  //             // Scopes
  //             Text('Available in:', style: TextStyle(color: _textSecondary)),
  //             SizedBox(height: 4),
  //             labels.isEmpty
  //                 ? Text('None', style: TextStyle(color: _textSecondary))
  //                 : Wrap(
  //                     spacing: 6,
  //                     runSpacing: 4,
  //                     children: labels
  //                         .map(
  //                           (lbl) => Chip(
  //                             label: Text(
  //                               lbl,
  //                               style: TextStyle(color: _textPrimary),
  //                             ),
  //                             backgroundColor: _chipColor,
  //                             padding: EdgeInsets.zero,
  //                           ),
  //                         )
  //                         .toList(),
  //                   ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(ctx).pop();
  //             },
  //             child: Text('Close', style: TextStyle(color: _accentColor)),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // import 'package:flutter/material.dart';
  // import 'package:voicefirst/Views/CompanySide/add_activity.dart';
  // // import 'add_activity_page.dart'; // Import the AddActivityPage

  // class AddBusiness extends StatefulWidget {
  //   const AddBusiness({super.key});

  //   @override
  //   State<AddBusiness> createState() => _AddBusinessState();
  // }

  // class _AddBusinessState extends State<AddBusiness> {
  //   List<Map<String, dynamic>> activities = [];

  //   void _addNewActivities(List<Map<String, dynamic>> newActivities) {
  //     setState(() {
  //       activities.addAll(newActivities); // Add all new activities to the list
  //     });
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(title: Text("Business Activities")),
  //       body: Column(
  //         children: [
  //           Expanded(
  //             child: activities.isEmpty
  //                 ? Center(child: Text('No activities added.'))
  //                 : ListView.builder(
  //                     itemCount: activities.length,
  //                     itemBuilder: (context, index) {
  //                       final activity = activities[index];
  //                       return ListTile(
  //                         title: Text(activity['business_activity_name']),
  //                         subtitle: Text('Company: ${activity['company']}'),
  //                       );
  //                     },
  //                   ),
  //           ),
  //           FloatingActionButton(
  //             onPressed: () {
  //               // Navigate to AddActivityPage
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) =>
  //                       AddActivityPage(onActivitiesAdded: _addNewActivities),
  //                 ),
  //               );
  //             },
  //             child: Icon(Icons.add),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }


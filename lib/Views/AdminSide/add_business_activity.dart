import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Widgets/dynamic_drawer.dart';

class AddBusinessactivity extends StatefulWidget {
  const AddBusinessactivity({super.key});

  @override
  State<AddBusinessactivity> createState() => _AddBusinessactivityState();
}

class _AddBusinessactivityState extends State<AddBusinessactivity> {
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

  final List<Map<String, dynamic>> activities = [
    {
      "id": "010110101",
      "business_activity_name": "Restaurant",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110111",
      "business_activity_name": "Textiles",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110011",
      "business_activity_name": "Jewellery",
      "company": "y",
      "branch": "y",
      "section": "n",
      "sub_section": "n",
    },
  ];

  @override
  void initState() {
    super.initState();
    loadMenu();
    filteredActivities = List.from(activities);
    _searchController.addListener(_filterActivities);
    // loadActivities();
  }

  Future<void> loadMenu() async {
    final url = Uri.parse('http://192.168.0.180:8064/api/menu/get-menu');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final items = (jsonData['data']['Items'] as List)
            .map((e) => MenuItem.fromJson(e))
            .toList();

        setState(() {
          menuItems = buildMenuTree(items);
        });
      } else {
        print('Menu fetch failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Menu load error: $e');
    }
  }

  List<MenuItem> buildMenuTree(List<MenuItem> flatList) {
    flatList.sort((a, b) => a.position.compareTo(b.position));
    Map<String, MenuItem> positionMap = {
      for (var item in flatList) item.position: item,
    };

    List<MenuItem> roots = [];

    for (var item in flatList) {
      if (item.position.length == 1) {
        roots.add(item);
      } else {
        final parentPos = item.position.substring(0, item.position.length - 1);
        if (positionMap.containsKey(parentPos)) {
          positionMap[parentPos]!.children = [
            ...positionMap[parentPos]!.children,
            item,
          ];
        }
      }
    }

    return roots;
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
      drawer: CustomDrawer(items: menuItems),
      appBar: AppBar(
        backgroundColor: _bgColor,
        iconTheme: IconThemeData(color: _accentColor),
        elevation: 0,
        title: Text(
          'Business Activities',
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

      // ─── FAB ────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        child: Icon(Icons.add, color: _bgColor),
        onPressed: () => _showAddDialog(context),
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
                  title: Text('Company', style: TextStyle(color: Colors.white)),
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/business_activity_model.dart';
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Views/CompanySide/BusinessActivity/existing_activity.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => AddBusinessState();
}

class AddBusinessState extends State<AddBusiness> {
  List<Map<String, dynamic>> activities = [];

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
  // final TextEditingController _newNameController = TextEditingController();
  // bool _newCompany = false;
  // bool _newBranch = false;
  // bool _newSection = false;
  // bool _newSubSection = false;

  //get existing activities

  bool isDataLoaded = false;

  Future<void> fetchBusinessActivities() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/company-business-activities/for-company',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final model = BusinessActivityModel.fromJson(json);

        if (model.isSuccess) {
          final fetched = model.data.map((activity) {
            return {
              'id': activity.id,
              'business_activity_name': activity.activityName,
              'company': activity.company ? 'y' : 'n',
              'branch': activity.branch ? 'y' : 'n',
              'section': activity.section ? 'y' : 'n',
              'sub_section': activity.subSection ? 'y' : 'n',
              'status': activity.status == true ? 'active' : 'inactive',

              // 'status': activity.status,
            };
          }).toList();

          setState(() {
            activities = fetched;
            filteredActivities = List.from(fetched);
            isDataLoaded = true;
          });
        } else {
          debugPrint('Error: ${model.message}');
        }
      } else {
        debugPrint('Failed to fetch activities: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
    }
  }

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
                // Navigator.of(ctx).pop();
                // // _showSelectExistingDialog(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExistingActivity()),
                );
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
                // ignore: avoid_types_as_parameter_names
                // AddActivityDialog(bgColor: _bgColor, accentColor: _accentColor, textPrimary: _textPrimary, textSecondary: _textSecondary, onAdd: (Map<String, dynamic> ) {  }, );
                // add(onActivitiesAdded: _addNewActivities);
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
              // _showEditDialog(ctx, activity);
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
}

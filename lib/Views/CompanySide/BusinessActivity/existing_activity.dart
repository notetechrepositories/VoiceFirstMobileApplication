//get all activities list from db

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/business_activity_model.dart';

class ExistingActivity extends StatefulWidget {
  const ExistingActivity({super.key});

  @override
  State<ExistingActivity> createState() => _ExistingActivityState();
}

class _ExistingActivityState extends State<ExistingActivity> {
  bool isMultiSelectMode = false;
  Set<String> selectedIds = {};

  bool isdataLoaded = false;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredActivities = [];
  List<Map<String, dynamic>> activities = [];

  //get existing activities

  Future<void> fetchBusinessActivities() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activities');

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
              // 'company': activity.company ? 'y' : 'n',
              // 'branch': activity.branch ? 'y' : 'n',
              // 'section': activity.section ? 'y' : 'n',
              // 'sub_section': activity.subSection ? 'y' : 'n',
              'status': activity.status == true ? 'active' : 'inactive',

              // 'status': activity.status,
            };
          }).toList();

          setState(() {
            activities = fetched;
            filteredActivities = List.from(fetched);
            isdataLoaded = true;
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

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      selectedIds.clear();
      if (selectAll) {
        // Select only the currently *visible* (filtered) items.
        selectedIds.addAll(filteredActivities.map((e) => e['id'] as String));
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isMultiSelectMode = false;
      selectedIds.clear();
    });
  }

  /// Are *all visible* items currently selected?
  bool get _allVisibleSelected =>
      filteredActivities.isNotEmpty &&
      selectedIds.length == filteredActivities.length;

  // ──────────────────────────────────────
  // Page-specific colour palette
  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text
  // ──────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // filteredActivities = List.from(activities);
    _searchController.addListener(_filterActivities);
    fetchBusinessActivities(); // fetch from API
    // loadActivities();
  }

  void _filterActivities() {
    if (!isdataLoaded) return; //Don't filter until data is ready

    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredActivities = List.from(activities);
      } else {
        filteredActivities = activities.where((activity) {
          final name = (activity['business_activity_name'] ?? '').toLowerCase();
          return name.contains(query);
        }).toList();
      }
      debugPrint("Searching in ${activities.length} items");
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
          isMultiSelectMode
              ? '${selectedIds.length} selected'
              : 'Business Activities',
          style: TextStyle(color: _textSecondary),
        ),
        actions: isMultiSelectMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    // final confirmed = await deleteactivities(
                    //   selectedIds.toList(),
                    // );
                    // if (confirmed) {
                    //   setState(() {
                    //     activities.removeWhere(
                    //       (x) => selectedIds.contains(x['id']),
                    //     );
                    //     // _filterActivities();
                    //     fetchBusinessActivities();
                    //     selectedIds.clear();
                    //     isMultiSelectMode = false;
                    //   });
                    // }
                  },
                ),
              ]
            : [],
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
          // ─── Selection controls ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: isMultiSelectMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _enterSelectionMode(
                            selectAll: !_allVisibleSelected,
                          ),
                          child: Text(
                            _allVisibleSelected ? 'Clear All' : 'Select All',
                            style: TextStyle(color: _accentColor),
                          ),
                        ),
                        TextButton(
                          onPressed: _exitSelectionMode,
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: _accentColor),
                          ),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: () => _enterSelectionMode(),
                      child: Text(
                        'Select',
                        style: TextStyle(color: _accentColor),
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
                      final isSelected = selectedIds.contains(a['id']);
                      final labels = <String>[];
                      if (a['company'] == 'y') labels.add('Company');
                      if (a['branch'] == 'y') labels.add('Branch');
                      if (a['section'] == 'y') labels.add('Section');
                      if (a['sub_section'] == 'y') labels.add('Sub-section');

                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            isMultiSelectMode = true;
                            selectedIds.add(a['id']);
                          });
                        },
                        onTap: () {
                          if (isMultiSelectMode) {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(a['id']);
                                if (selectedIds.isEmpty) {
                                  isMultiSelectMode = false; // auto-exit
                                }
                              } else {
                                selectedIds.add(a['id']);
                              }
                            });
                          } else {
                        
                          }
                        },
                        child: Card(
                          color: isMultiSelectMode && isSelected
                              ? Colors.grey[700]
                              : _cardColor,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ─ Left: just the name ───────────
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a['business_activity_name'] ?? '',
                                        style: TextStyle(
                                          color: _textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                  ),
                                ),

                                
                                // if (!isMultiSelectMode)
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedIds.add(a['id']);
                                      } else {
                                        selectedIds.remove(a['id']);
                                        if (selectedIds.isEmpty) {
                                          isMultiSelectMode = false;
                                        }
                                      }
                                    });
                                  },
                                  activeColor: _accentColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

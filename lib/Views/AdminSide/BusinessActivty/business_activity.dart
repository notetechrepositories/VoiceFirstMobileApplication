import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Widgets/snack_bar.dart';
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Models/business_activity_model.dart';
import 'package:voicefirst/Views/AdminSide/BusinessActivty/add_activity_dialog.dart';
import 'package:voicefirst/Views/AdminSide/BusinessActivty/edit_activity_dialog.dart';
import 'package:voicefirst/Views/AdminSide/BusinessActivty/view_activity_dialog.dart';
import '../../../Core/Constants/api_endpoins.dart';

class AddBusinessactivity extends StatefulWidget {
  const AddBusinessactivity({super.key});

  @override
  State<AddBusinessactivity> createState() => _AddBusinessactivityState();
}

class _AddBusinessactivityState extends State<AddBusinessactivity> {
  Future<bool> deleteactivities(List<String> id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activities');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(id),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['isSuccess'] == true;
      } else {
        debugPrint('delete failed with status:${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      return false;
    }
  }

  Future<void> _submitActivityToApi({
    required String name,
    required bool company,
    required bool branch,
    required bool section,
    required bool subSection,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activities');
    final body = {
      "activityName": name,
      "company": company,
      "branch": branch,
      "section": section,
      "subSection": subSection,
    };

    try {
      debugPrint('Sending: ${jsonEncode(body)}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);
      if (json['isSuccess'] == true) {
        fetchBusinessActivities();
        SnackbarHelper.showSuccess('Activity added successfully');
      } else {
        final errorMessage = json['message'] ?? 'Failed to add activity';
        SnackbarHelper.showError(errorMessage);
      }
    } catch (e) {
      debugPrint('Error: $e');
      SnackbarHelper.showError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>?> _updateActivityOnServer(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activities');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('Activity updated successfully.');
        SnackbarHelper.showSuccess('Activity updated successfully.');
        return json['data'];
      } else if (response.statusCode == 409) {
        // Handle "already exists" conflict
        SnackbarHelper.showError('Activity already exists.');
      } else {
        // Handle other API errors
        SnackbarHelper.showError('Failed to update activity.');
        debugPrint('Failed to update activity: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      debugPrint('Error updating activity: $e');
      SnackbarHelper.showError('An unexpected error occurred.');
      return null;
    }
  }

  //update status
  Future<bool> _updateStatusOnServer(String id, bool status) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activities');

    final body = {'id': id, 'status': status};

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('Status updated to $status');
        return true;
        // return data['isSuccess'] == true;
      } else if (response.statusCode == 409) {
        // Conflict: activity already exists or similar business rule violation
        _showConflictDialog(); // <-- Call custom dialog
        return false;
      } else {
        debugPrint('Failed to update status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  //get all activities list from db

  Future<void> fetchBusinessActivities() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activities/all');

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

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredActivities = [];
  List<Map<String, dynamic>> activities = [];

  List<MenuItem> menuItems = [];

  //for deletion

  bool isMultiSelectMode = false;
  Set<String> selectedIds = {};

  bool isdataLoaded = false;

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
                    final confirmed = await deleteactivities(
                      selectedIds.toList(),
                    );
                    if (confirmed) {
                      setState(() {
                        activities.removeWhere(
                          (x) => selectedIds.contains(x['id']),
                        );
                        // _filterActivities();
                        fetchBusinessActivities();
                        selectedIds.clear();
                        isMultiSelectMode = false;
                      });
                    }
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
                            showDialog(
                              context: context,
                              builder: (_) => ViewActivityDialog(
                                activity:
                                    a, // <- this is correct, 'a' from your list item
                                onEdit: () => showDialog(
                                  context: context,
                                  builder: (_) => EditActivityDialog(
                                    activity: a,
                                    cardColor: _cardColor,
                                    textPrimary: _textPrimary,
                                    textSecondary: _textSecondary,
                                    accentColor: _accentColor,
                                    onUpdate: _updateActivityOnServer,
                                    onUpdated: () => setState(() {
                                      _filterActivities();
                                    }),
                                    onCancel: () {},
                                  ),
                                ),
                                cardColor: _cardColor,
                                chipColor: _chipColor,
                                textPrimary: _textPrimary,
                                textSecondary: _textSecondary,
                                accentColor: _accentColor,
                              ),
                            );
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

                                // ─ Right: eye, edit, delete ─────
                                if (!isMultiSelectMode) ...[
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.60,
                                        child: Switch(
                                          value: a['status'] == 'active',
                                          activeColor: Colors.green,
                                          onChanged: (val) async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirm'),
                                                content: Text(
                                                  'Are you sure you want to ${val ? 'activate' : 'deactivate'} this activity?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: Text('Yes'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              final success =
                                                  await _updateStatusOnServer(
                                                    a['id'],
                                                    val,
                                                  );
                                              if (success) {
                                                setState(() {
                                                  a['status'] = val
                                                      ? 'active'
                                                      : 'inactive';
                                                });
                                                SnackbarHelper.showSuccess(
                                                  'Status Updated',
                                                );
                                              } else {
                                                SnackbarHelper.showError(
                                                  'Failed to update Status',
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Confirm'),
                                          content: Text(
                                            'Are you sure you want to delete this activity?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final success = await deleteactivities([
                                          a['id'],
                                        ]);
                                        if (success) {
                                          setState(() {
                                            activities.removeWhere(
                                              (x) => x['id'] == a['id'],
                                            );
                                            fetchBusinessActivities(); // optional
                                          });
                                          SnackbarHelper.showSuccess(
                                            'Activity Deleted',
                                          );
                                        } else {
                                          SnackbarHelper.showError(
                                            'Failed to delete activity',
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ] else
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

      //  ─── FAB ────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        child: Icon(Icons.add, color: _bgColor),

        // onPressed: () => _showAddDialog(context),// when within the same page

        //when dialog is in different page
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddBusinessActivityDialog(
              onSubmit:
                  ({
                    required String name,
                    required bool company,
                    required bool branch,
                    required bool section,
                    required bool subSection,
                  }) async {
                    await _submitActivityToApi(
                      name: name,
                      company: company,
                      branch: branch,
                      section: section,
                      subSection: subSection,
                    );
                  },
            ),
          );
        },
      ),
    );
  }

  void _showConflictDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Conflict'),
        content: Text(
          'This activity already exists or conflicts with another entry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
import 'package:voicefirst/Models/company_business_activity_model.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';
// import 'package:voicefirst/Views/AdminSide/BusinessActivty/add_activity_dialog.dart';
// import 'package:voicefirst/Views/AdminSide/BusinessActivty/edit_activity_dialog.dart';
// import 'package:voicefirst/Views/AdminSide/BusinessActivty/view_activity_dialog.dart';

class CompanyBusinessActivity extends StatefulWidget {
  const CompanyBusinessActivity({super.key});

  @override
  State<CompanyBusinessActivity> createState() =>
      _CompanyBusinessActivityState();
}

class _CompanyBusinessActivityState extends State<CompanyBusinessActivity> {
  final Dio _dio = ApiClient().dio;
  // ──────────────────────────────────────
  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text
  // ──────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  List<CompanyBusinessActivityModel> filteredActivities = [];
  List<CompanyBusinessActivityModel> activities = [];

  // List<MenuItem> menuItems = [];

  //for deletion

  bool isMultiSelectMode = false;
  Set<String> selectedIds = {};

  bool isdataLoaded = false;

  Future<bool> deleteactivities(List<String> ids) async {
    try {
      final response = await _dio.delete(
        '/company-business-activities',
        data: ids,
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['isSuccess'] == true) {
        // final json = jsonDecode(response.body);
        return true;
      } else {
        debugPrint(
          'delete failed with status:${response.statusCode} ${response.data}',
        );
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error deleting activity: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      return false;
    }
  }

  // Future<void> _addActivity({
  //   required String name,
  //   required bool isForCompany,
  //   required bool isForBranch,
  // }) async {
  //   final body = {
  //     "activityName": name,
  //     "isForCompany": isForCompany,
  //     "isForBranch": isForBranch,
  //   };

  //   try {
  //     final res = await _dio.post('/business-activities', data: body);

  //     if (res.statusCode == 200 &&
  //         res.data is Map<String, dynamic> &&
  //         res.data['isSuccess'] == true) {
  //       final data = res.data['data'];
  //       if (data is Map<String, dynamic>) {
  //         final created = BusinessActivity.fromJson(data);
  //         setState(() {
  //           final idx = activities.indexWhere((x) => x.id == created.id);
  //           if (idx >= 0) {
  //             activities[idx] = created;
  //           } else {
  //             activities.add(created); // append new item
  //           }
  //           _filterActivities();
  //         });
  //       }
  //       // SnackbarHelper.showSuccess('Activity added successfully');
  //     } else if (res.statusCode == 409 ||
  //         (res.data is Map &&
  //             ((res.data['errorType']?.toString().toLowerCase() ==
  //                     'duplicate') ||
  //                 (res.data['message']?.toString().toLowerCase().contains(
  //                       'exist',
  //                     ) ??
  //                     false)))) {
  //       final msg = (res.data is Map && res.data['message'] != null)
  //           ? res.data['message'].toString()
  //           : 'Activity already exists.';
  //       // SnackbarHelper.showError(msg);
  //       debugPrint(msg);
  //     } else {
  //       final msg = (res.data is Map && res.data['message'] != null)
  //           ? res.data['message'].toString()
  //           : 'failed to add activity';
  //       debugPrint(msg);
  //       // SnackbarHelper.showError(msg);
  //     }
  //   } on DioException catch (e) {
  //     //  409  error
  //     if (e.response?.statusCode == 409) {
  //       final msg = e.response?.data is Map<String, dynamic>
  //           ? (e.response!.data['message']?.toString() ??
  //                 'Activity already exists.')
  //           : 'Activity already exists.';
  //       // SnackbarHelper.showError(msg);
  //       debugPrint(msg);
  //       return;
  //     }

  //     final msg = e.response?.data is Map<String, dynamic>
  //         ? (e.response!.data['message']?.toString() ?? e.message)
  //         : e.message;
  //     SnackbarHelper.showError('Failed to add activity: $msg');
  //   } catch (e) {
  //     SnackbarHelper.showError('Something went wrong. Please try again.');
  //   }
  // }

  //status update
  Future<bool> _updateStatus(String id, bool status) async {
    try {
      final res = await _dio.patch(
        '/company-business-activities',
        data: {'id': id, 'status': status},
      );
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['isSuccess'] == true) {
        debugPrint('Status Updated Successfully');
        // SnackbarHelper.showSuccess('Status Updated');
        return true;
      } else if (res.statusCode == 409) {
        _showConflictDialog();
        return false;
      } else {
        debugPrint('Failed to update status : ${res.statusCode} ${res.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error updating status : ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  //append to list from response

  // Future<Map<String, dynamic>?> _updateActivity(
  //   Map<String, dynamic> body,
  // ) async {
  //   try {
  //     final res = await _dio.put(
  //       '/business-activities',
  //       data: body,
  //     ); // still sending only changed fields + id

  //     if (res.statusCode == 200 &&
  //         res.data is Map<String, dynamic> &&
  //         res.data['isSuccess'] == true) {
  //       final data = res.data['data'];

  //       //  update local lists (replace by id or append)
  //       if (data is Map<String, dynamic>) {
  //         final updated = BusinessActivity.fromJson(data);
  //         setState(() {
  //           final idx = activities.indexWhere((x) => x.id == updated.id);
  //           if (idx >= 0) {
  //             activities[idx] = updated;
  //           } else {
  //             activities.add(updated);
  //           }
  //           _filterActivities(); // keep filteredActivities in sync
  //         });
  //       }

  //       // SnackbarHelper.showSuccess('Activity updated successfully.');
  //       return (data is Map<String, dynamic>) ? data : null;
  //     } else if (res.statusCode == 409) {
  //       SnackbarHelper.showError('Activity already exists.');
  //       return null;
  //     } else {
  //       final msg = (res.data is Map && res.data['message'] != null)
  //           ? res.data['message'].toString()
  //           : 'Failed to update activity.';
  //       SnackbarHelper.showError(msg);
  //       return null;
  //     }
  //   } on DioException catch (e) {
  //     final msg = e.response?.data is Map<String, dynamic>
  //         ? (e.response!.data['message']?.toString() ?? e.message)
  //         : e.message;
  //     SnackbarHelper.showError('failed to update activity: $msg');
  //     return null;
  //   } catch (e) {
  //     SnackbarHelper.showError('An unexpected error occurred.');
  //     return null;
  //   }
  // }


Future<Map<String, dynamic>?> _updateActivity(Map<String, dynamic> body) async {
  try {
    final res = await _dio.put(
      '/company-business-activities',
      data: {
        'id': body['id'],
        'activityName': body['activityName'],
      },
    );

    if (res.statusCode == 200 &&
        res.data is Map<String, dynamic> &&
        res.data['isSuccess'] == true) {
      final data = res.data['data'];
      if (data is Map<String, dynamic>) {
        final updated = CompanyBusinessActivityModel.fromJson(data);
        setState(() {
          final idx = activities.indexWhere((x) => x.id == updated.id);
          if (idx >= 0) {
            activities[idx] = updated;
          } else {
            activities.add(updated);
          }
          _filterActivities();
        });
      }
      return data is Map<String, dynamic> ? data : null;
    } else {
      final msg = (res.data is Map && res.data['message'] != null)
          ? res.data['message'].toString()
          : 'Failed to update activity.';
      SnackbarHelper.showError(msg);
      return null;
    }
  } on DioException catch (e) {
    final msg = e.response?.data is Map<String, dynamic>
        ? (e.response!.data['message']?.toString() ?? e.message)
        : e.message;
    SnackbarHelper.showError('failed to update activity: $msg');
    return null;
  } catch (e) {
    SnackbarHelper.showError('An unexpected error occurred.');
    return null;
  }
}


  //update status
  //get all activities list from db
  //using dio and activity model
  // Future<void> fetchBusinessActivities() async {
  //   try {
  //     // baseUrl already set in ApiClient; token added by interceptor
  //     final res = await _dio.get('/company-business-activities/all');

  //     if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
  //       final model = CompanyBusinessActivityResponse.fromJson(
  //         res.data as Map<String, dynamic>,
  //       );

  //       if (model.isSuccess) {
  //         setState(() {
  //           activities = model.data; // List<BusinessActivity>
  //           filteredActivities = List.from(model.data);
  //           isdataLoaded = true;
  //         });
  //       } else {
  //         debugPrint('Error from API: ${model.message}');
  //       }
  //     } else {
  //       final msg = (res.data is Map && res.data['message'] != null)
  //           ? res.data['message'].toString()
  //           : 'Invalid API response';
  //       debugPrint('Failed to fetch activities: $msg');
  //     }
  //   } on DioException catch (e) {
  //     final msg = e.response?.data is Map<String, dynamic>
  //         ? (e.response!.data['message']?.toString() ?? e.message)
  //         : e.message;
  //     debugPrint('Failed to fetch activities: $msg');
  //   } catch (e) {
  //     debugPrint('Exception occurred: $e');
  //   }
  // }

  Future<void> fetchBusinessActivities() async {
    try {
      final res = await _dio.get('/company-business-activities/all');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final model = CompanyBusinessActivityResponse.fromJson(
          (res.data as Map).cast<String, dynamic>(),
        );
        if (model.isSuccess) {
          setState(() {
            activities = model.data;
            filteredActivities = List.of(activities);
            isdataLoaded = true;
          });
        } else {
          debugPrint('API error: ${model.message}');
        }
      } else {
        final msg = (res.data is Map && res.data['message'] is String)
            ? res.data['message'] as String
            : 'Invalid API response';
        debugPrint('Failed to fetch: $msg');
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data is Map && e.response!.data['message'] is String
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      debugPrint('Fetch error: $msg');
    } catch (e) {
      debugPrint('Exception: $e');
    }
  }

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      selectedIds.clear();
      if (selectAll) {
        selectedIds.addAll(filteredActivities.map((e) => e.id));
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

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterActivities);
    fetchBusinessActivities(); // fetch from API
  }

  void _filterActivities() {
    if (!isdataLoaded) return; //Don't filter until data is loaded

    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredActivities = List.from(activities);
      } else {
        filteredActivities = activities
            .where((a) => a.activityName.toLowerCase().contains(query))
            .toList();
        // filteredActivities = activities.where((activity) {
        //   // final name = (activity['business_activity_name'] ?? '').toLowerCase();
        //   return activity.activityName.toLowerCase().contains(query);
        // }).toList();
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
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm'),
                        content: Text(
                          'Delete ${selectedIds.length} selected activities?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;

                    final confirmed = await deleteactivities(
                      selectedIds.toList(),
                    );
                    if (confirmed) {
                      setState(() {
                        activities.removeWhere(
                          (x) => selectedIds.contains(x.id),
                        );
                        // fetchBusinessActivities();
                        selectedIds.clear();
                        isMultiSelectMode = false;
                        _filterActivities(); // keep filtered list in sync
                      });
                      SnackbarHelper.showSuccess('Activities deleted');
                    } else {
                      SnackbarHelper.showError('Failed to delete activities');
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
                      final isSelected = selectedIds.contains(a.id);
                      final labels = <String>[];
                      // if (a.isForCompany == true) labels.add('Company');
                      // if (a.isForBranch == true) labels.add('Branch');
                      // if (a['section'] == 'y') labels.add('Section');
                      // if (a['sub_section'] == 'y') labels.add('Sub-section');

                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            isMultiSelectMode = true;
                            selectedIds.add(a.id);
                          });
                        },
                        onTap: () {
                          if (isMultiSelectMode) {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(a.id);
                                if (selectedIds.isEmpty) {
                                  isMultiSelectMode = false; // auto-exit
                                }
                              } else {
                                selectedIds.add(a.id);
                              }
                            });
                          } else {
                            // showDialog(
                            //   context: context,
                            //   builder: (_) => ViewActivityDialog(
                            //     activity: a,
                            //     onEdit: () => showDialog(
                            //       context: context,
                            //       builder: (_) => EditActivityDialog(
                            //         activity: a,
                            //         cardColor: _cardColor,
                            //         textPrimary: _textPrimary,
                            //         textSecondary: _textSecondary,
                            //         accentColor: _accentColor,
                            //         onUpdate: _updateActivity,
                            //         onUpdated: () => setState(() {
                            //           _filterActivities();
                            //         }),
                            //         onCancel: () {},
                            //       ),
                            //     ),
                            //     cardColor: _cardColor,
                            //     chipColor: _chipColor,
                            //     textPrimary: _textPrimary,
                            //     textSecondary: _textSecondary,
                            //     accentColor: _accentColor,
                            //   ),
                            // );
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
                                        a.activityName,
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
                                          value: a.status,
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
                                                        ).pop(),
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
                                                  await _updateStatus(
                                                    a.id,
                                                    val,
                                                  );
                                              if (success) {
                                                setState(() {
                                                  final updated = a.copyWith(
                                                    status: val,
                                                  );

                                                  //update list
                                                  final idx = activities
                                                      .indexWhere(
                                                        (x) => x.id == a.id,
                                                      );
                                                  if (idx != -1) {
                                                    activities[idx] = updated;
                                                    _filterActivities();
                                                  }
                                                });
                                                // simplest: refetch so both lists stay in sync
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
                                          a.id,
                                        ]);
                                        if (success) {
                                          setState(() {
                                            activities.removeWhere(
                                              (x) => x.id == a.id,
                                            );
                                            _filterActivities();
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
                                          selectedIds.add(a.id);
                                        } else {
                                          selectedIds.remove(a.id);
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
        // onPr essed: () => _showAddDialog(context),// when within the same page
        //when dialog is in different page
        onPressed: () {
          // showDialog(
          //   context: context,
          //   builder: (_) => AddBusinessActivityDialog(
          //     onSubmit: (activity) async {
          //       // await _addActivity(
          //       //   name: activity.activityName,
          //       //   isForCompany: activity.isForCompany,
          //       //   isForBranch: activity.isForBranch,
          //       //   // section: section,
          //       //   // subSection: subSection,
          //       // );
          //     },
          //   ),
          // );
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

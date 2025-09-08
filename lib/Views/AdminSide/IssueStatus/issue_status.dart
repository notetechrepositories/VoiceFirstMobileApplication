import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
import 'package:voicefirst/Models/issue_status_model.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';

class IssueStatus extends StatefulWidget {
  const IssueStatus({super.key});

  @override
  State<IssueStatus> createState() => _IssueStatusState();
}

class _IssueStatusState extends State<IssueStatus> {
  List<IssueStatusModel> _IssueStatus = [];
  List<IssueStatusModel> _filtered = [];
  bool isMultiSelectMode = false;
  final Set<String> _selectedIds = {};

  // final Set<String> _selectedIds = {};

  final _searchController = TextEditingController();
  String _statusFilter = "All";

  final Dio _dio = ApiClient().dio;

  final Color _accentColor = Color(0xFFFCC737); // gold accent

  @override
  void initState() {
    super.initState();
    _fetchIssueStatuss();
  }

  Future<void> _fetchIssueStatuss() async {
    try {
      final res = await _dio.get('/issue-status/all');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        // final data = jsonDecode(res.body);
        final List list =
            (res.data['data'] as List?) ??
            []; // Fetching the data array from the response

        setState(() {
          _IssueStatus = list
              .map(
                (e) => IssueStatusModel.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList();
          _applyFilters();
        });
      }
    } on DioException catch (e) {
      debugPrint('failed to fetch company issue status : ${e.message}');
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _IssueStatus.where((item) {
        final matchesText = item.issueStatus.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        final matchesStatus =
            _statusFilter == 'All' ||
            (_statusFilter == 'Active' && item.status) ||
            (_statusFilter == 'Inactive' && !item.status);
        return matchesText && matchesStatus;
      }).toList();
    });
  }

  Future<void> _showAddEditDialog({IssueStatusModel? existing}) async {
    final controller = TextEditingController(text: existing?.issueStatus ?? '');
    final isEditing = existing != null;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            isEditing ? 'Edit Issue Status' : 'Add Issue Status',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter Issue Status Name",
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[850],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCC737),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                try {
                  const path = '/issue-status';
                  final res = isEditing
                      ? await _dio.put(
                          path,
                          data: {'id': existing.id, 'issueStatus': name},
                        )
                      : await _dio.post(path, data: {'issueStatus': name});

                  if ((res.statusCode ?? 0) == 200 ||
                      (res.statusCode ?? 0) == 201) {
                    if (res.data is Map && res.data['isSuccess'] == true) {
                      if (context.mounted) Navigator.pop(ctx);
                      await _fetchIssueStatuss();
                    } else {
                      // show backend message
                      final msg =
                          (res.data is Map && res.data['message'] is String)
                          ? res.data['message'] as String
                          : 'Operation failed.';
                      Navigator.of(context).pop();
                      SnackbarHelper.showError(msg);
                    }
                  } else {
                    // non-200 - show backend message if present
                    final msg =
                        (res.data is Map && res.data['message'] is String)
                        ? res.data['message'] as String
                        : 'Request failed.';
                    Navigator.of(context).pop();
                    SnackbarHelper.showError(msg);
                  }
                } on DioException catch (e) {
                  // show backend message from error response if present
                  final msg =
                      (e.response?.data is Map &&
                          e.response!.data['message'] is String)
                      ? e.response!.data['message'] as String
                      : (e.message ?? 'Request failed');
                  Navigator.of(context).pop();
                  SnackbarHelper.showError(msg);
                }
              },
              child: Text(isEditing ? 'Save Changes' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleAnswerStatus(IssueStatusModel issueStatus) async {
    final newStatus = !issueStatus.status;
    try {
      final url = '/issue-status';
      // final body = jsonEncode({"id": issueStatus.id, "status": newStatus});

      final response = await _dio.patch(
        url,
        data: {'Id': issueStatus.id, 'Status': newStatus},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['isSuccess'] == true) {
        // final result = jsonDecode(response.data);

        setState(() {
          issueStatus.status = newStatus;
          _applyFilters();
        });
        SnackbarHelper.showSuccess("Status updated");
      } else {
        debugPrint('update failed : ${response.data}');
        SnackbarHelper.showError('Failed to update status');
      }
    } on DioException catch (e) {
      debugPrint(
        'Toggle error: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
      SnackbarHelper.showError('failed to update status ');
    }
  }

  // Future<void> _deleteSelected() async {
  //   if (_selectedIds.isEmpty) return;

  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text("Confirm Delete"),
  //       content: Text("Are you sure you want to delete selected items?"),
  //       actions: [
  //         TextButton(
  //           child: Text("Cancel"),
  //           onPressed: () => Navigator.pop(ctx, false),
  //         ),
  //         ElevatedButton(
  //           child: Text("Delete"),
  //           onPressed: () => Navigator.pop(ctx, true),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm != true) return;
  //   try {
  //     final url = '/issue-status';
  //     final res = await _dio.delete(
  //       url,
  //       data: jsonEncode(_selectedIds.toList()),
  //     );

  //     if (res.statusCode == 200 &&
  //         res.data is Map<String, dynamic> &&
  //         res.data['isSuccess'] == true) {
  //       setState(() {
  //         _IssueStatus.removeWhere((e) => _selectedIds.contains(e.id));
  //         _selectedIds.clear();
  //         _applyFilters();
  //       });
  //       SnackbarHelper.showSuccess("Items deleted");
  //     } else {
  //       final msg = (res.data is Map && res.data['message'] is String)
  //           ? res.data['message'] as String
  //           : 'Failed to delete items';
  //       SnackbarHelper.showError(msg);
  //     }
  //   } on DioException catch (e) {
  //     final msg =
  //         (e.response?.data is Map && (e.response!.data['message'] is String))
  //         ? e.response!.data['message'] as String
  //         : (e.message ?? 'Request failed');
  //     SnackbarHelper.showError('Failed to delete items: $msg');
  //   }
  // }

  // Future<bool> _deleteIssueStatuses(List<String> ids) async {
  //   try {
  //     final res = await _dio.delete('/issue-status', data: ids);
  //     return res.statusCode == 200 &&
  //         res.data is Map<String, dynamic> &&
  //         res.data['isSuccess'] == true;
  //   } on DioException catch (e) {
  //     debugPrint('Delete failed: ${e.response?.data ?? e.message}');
  //     return false;
  //   } catch (e) {
  //     debugPrint('Delete failed: $e');
  //     return false;
  //   }
  // }

  Future<void> _deleteIssueStatuses(
    List<String> ids, {
    String? labelForSingle,
  }) async {
    if (ids.isEmpty) return;
    final isBulk = ids.length > 1;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(
          isBulk
              ? 'Delete ${ids.length} selected items?'
              : 'Delete "${labelForSingle ?? 'this item'}"?',
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

    try {
      final res = await _dio.delete('/issue-status', data: ids);
      final success =
          res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['isSuccess'] == true;

      if (success) {
        setState(() {
          _IssueStatus.removeWhere((e) => ids.contains(e.id));
          _filtered.removeWhere((e) => ids.contains(e.id));
          _selectedIds.removeAll(ids);
          if (_selectedIds.isEmpty) isMultiSelectMode = false;
        });
        SnackbarHelper.showSuccess(
          isBulk ? 'Items deleted' : 'Issue status deleted',
        );
      } else {
        final msg = (res.data is Map && res.data['message'] is String)
            ? res.data['message'] as String
            : 'Failed to delete ${isBulk ? 'items' : 'item'}';
        SnackbarHelper.showError(msg);
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data is Map && e.response!.data['message'] is String
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      SnackbarHelper.showError('Failed to delete: $msg');
    } catch (e) {
      SnackbarHelper.showError('Failed to delete: $e');
    }
  }

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      _selectedIds.clear();
      if (selectAll) {
        _selectedIds.addAll(_filtered.map((e) => e.id));
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isMultiSelectMode = false;
      _selectedIds.clear();
    });
  }

  /// Are *all visible* items currently selected?
  bool get _allVisibleSelected =>
      _filtered.isNotEmpty && _selectedIds.length == _filtered.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Manage Issue Status'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => _deleteIssueStatuses(_selectedIds.toList()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Color(0xFFFCC737),
        foregroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  value: _statusFilter,
                  iconEnabledColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  items: ['All', 'Active', 'Inactive']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _statusFilter = val!);
                    _applyFilters();
                  },
                ),
              ],
            ),
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
            const SizedBox(height: 12),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No Issue Statuss Found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final issueStatus = _filtered[i];
                        final isSelected = _selectedIds.contains(
                          issueStatus.id,
                        );

                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            // leading: Checkbox(
                            //   value: isSelected,
                            //   onChanged: (val) {
                            //     setState(() {
                            //       if (val == true) {
                            //         _selectedIds.add(issueStatus.id);
                            //       } else {
                            //         _selectedIds.remove(issueStatus.id);
                            //       }
                            //     });
                            //   },
                            // ),
                            //enter multiselectmode
                            onLongPress: () {
                              setState(() {
                                isMultiSelectMode = true;
                                _selectedIds.add(issueStatus.id);
                              });
                            },
                            onTap: () {
                              if (isMultiSelectMode) {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(issueStatus.id);
                                    if (_selectedIds.isEmpty) {
                                      isMultiSelectMode = false;
                                    }
                                  } else {
                                    _selectedIds.add(issueStatus.id);
                                  }
                                });
                              } else {
                                debugPrint('taped');
                              }
                            },

                            //showcheck ox for selection
                            leading: isMultiSelectMode
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selectedIds.add(issueStatus.id);
                                        } else {
                                          _selectedIds.remove(issueStatus.id);
                                          if (_selectedIds.isEmpty) {
                                            isMultiSelectMode = false;
                                          }
                                        }
                                      });
                                    },
                                  )
                                : null,

                            title: Text(
                              issueStatus.issueStatus,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: !isMultiSelectMode
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: issueStatus.status,
                                          activeColor: Colors.green,
                                          inactiveThumbColor: Colors.redAccent,
                                          onChanged: (val) async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Confirm'),
                                                content: Text(
                                                  'Are you sure want to ${val ? 'activate' : 'deactivate'} this issue status?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text('cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await _toggleAnswerStatus(
                                                issueStatus,
                                              );
                                            }
                                          },
                                        ),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () => _showAddEditDialog(
                                          existing: issueStatus,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteIssueStatuses(
                                          [issueStatus.id],
                                          labelForSingle:
                                              issueStatus.issueStatus,
                                        ),
                                        icon: const Icon(
                                          Icons.delete_outlined,
                                          color: Colors.redAccent,
                                        ),
                                      ),

                                      //single delete
                                      // IconButton(
                                      //   onPressed: () async {
                                      //     final ok = await showDialog(
                                      //       context: context,
                                      //       builder: (context) => AlertDialog(
                                      //         title: const Text('Confirm'),
                                      //         content: Text(
                                      //           'Are you sure want to delete "${issueStatus.issueStatus}"?',
                                      //         ),
                                      //         actions: [
                                      //           TextButton(
                                      //             onPressed: () => Navigator.of(
                                      //               context,
                                      //             ).pop(false),
                                      //             child: const Text('Cancel'),
                                      //           ),
                                      //           TextButton(
                                      //             onPressed: () => Navigator.of(
                                      //               context,
                                      //             ).pop(true),
                                      //             child: const Text('Yes'),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     );
                                      //     if (ok != true) return;

                                      //     final success =
                                      //         await _deleteIssueStatuses([
                                      //           issueStatus.id,
                                      //         ]);
                                      //     if (success) {
                                      //       setState(() {
                                      //         _IssueStatus.removeWhere(
                                      //           (e) => e.id == issueStatus.id,
                                      //         );
                                      //         _filtered.removeWhere(
                                      //           (e) => e.id == issueStatus.id,
                                      //         );
                                      //       });
                                      //       SnackbarHelper.showSuccess(
                                      //         'Issue Status deleted',
                                      //       );
                                      //     } else {
                                      //       SnackbarHelper.showError(
                                      //         'Failed to delete issue status',
                                      //       );
                                      //     }
                                      //   },
                                      //   icon: const Icon(
                                      //     Icons.delete_outlined,
                                      //     color: Colors.redAccent,
                                      //   ),
                                      // ),
                                    ],
                                  )
                                : null,
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
}

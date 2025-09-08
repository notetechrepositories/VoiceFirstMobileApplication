import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
import 'package:voicefirst/Models/company_issue_status_model.dart';
import 'package:voicefirst/Views/CompanySide/CompanyIssueStatus/existing_status.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';

class CompanyIssueStatus extends StatefulWidget {
  const CompanyIssueStatus({super.key});

  @override
  State<CompanyIssueStatus> createState() => _CompanyIssueStatusState();
}

class _CompanyIssueStatusState extends State<CompanyIssueStatus> {
  List<CompanyIssuestatusModel> _companyIssueStatus = [];
  List<CompanyIssuestatusModel> _filtered = [];

  bool isMultiSelectMode = false;
  final Set<String> _selectedIds = {};

  final _searchController = TextEditingController();
  String _statusFilter = "All";

  final Dio _dio = ApiClient().dio;

  final Color _cardColor = Color(0xFF262626); // dark grey card
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text

  @override
  void initState() {
    super.initState();
    _fetchIssueStatuss();
  }

  Future<void> _fetchIssueStatuss() async {
    try {
      final res = await _dio.get('/company-issue-status/all');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        // final data = jsonDecode(res.body);
        final List list =
            (res.data['data'] as List?) ??
            []; // Fetching the data array from the response

        setState(() {
          _companyIssueStatus = list
              .map(
                (e) => CompanyIssuestatusModel.fromJson(
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
      _filtered = _companyIssueStatus.where((item) {
        final matchesText = item.companyIssueStatus.toLowerCase().contains(
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
 
  Future<void> _showAddEditDialog({CompanyIssuestatusModel? existing}) async {
    final controller = TextEditingController(
      text: existing?.companyIssueStatus ?? '',
    );
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
                  const path = '/company-issue-status';

                  final res = isEditing
                      ? await _dio.put(
                          path,
                          data: {
                            'id': existing.id, // was 'Id'
                            'companyIssueStatus': name, // correct key
                          },
                        )
                      : await _dio.post(
                          path,
                          data: {
                            'companyIssueStatus': name, // correct key
                          },
                        );

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
                    // non-200 → show backend message if present
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

  Future<void> _toggleAnswerStatus(
    CompanyIssuestatusModel companyIssueStatus,
  ) async {
    final newStatus = !companyIssueStatus.status;
    try {
      final url = '/company-issue-status';
      // final body = jsonEncode({"id": companyIssueStatus.id, "status": newStatus});

      final response = await _dio.patch(
        url,
        data: {'Id': companyIssueStatus.id, 'Status': newStatus},
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['isSuccess'] == true) {
        // final result = jsonDecode(response.data);

        setState(() {
          companyIssueStatus.status = newStatus;
          _applyFilters();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Status updated")));
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

  Future<void> _deleteSelected({
    List<String>? ids, // pass for single delete
    String? labelForSingle, // optional nicer label in dialog
  }) async {
    // choose target IDs
    final targetIds = (ids != null && ids.isNotEmpty)
        ? ids
        : _selectedIds.toList();

    if (targetIds.isEmpty) return;

    final isBulk = targetIds.length > 1;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          isBulk
              ? 'Are you sure you want to delete ${targetIds.length} items?'
              : 'Are you sure you want to delete "${labelForSingle ?? 'this item'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final res = await _dio.delete(
        '/company-issue-status',
        data: targetIds, // JSON array
        options: Options(contentType: 'application/json'),
      );

      final success =
          res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['isSuccess'] == true;

      if (success) {
        setState(() {
          _companyIssueStatus.removeWhere((e) => targetIds.contains(e.id));
          _filtered.removeWhere((e) => targetIds.contains(e.id));
          _selectedIds.removeAll(targetIds);
          if (_selectedIds.isEmpty) isMultiSelectMode = false;
        });
        SnackbarHelper.showSuccess(isBulk ? 'Items deleted' : 'Item deleted');
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
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _deleteSelected(), // uses current selection
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChoiceDialog(context),
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
                        final companyIssueStatus = _filtered[i];
                        final isSelected = _selectedIds.contains(
                          companyIssueStatus.id,
                        );
                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            // leading: Checkbox(
                            //   value: isSelected,
                            //   onChanged: (val) {
                            //     setState(() {
                            //       if (val == true) {
                            //         _selectedIds.add(companyIssueStatus.id);
                            //       } else {
                            //         _selectedIds.remove(companyIssueStatus.id);
                            //       }
                            //     });
                            //   },
                            // ),
                            //change
                            onLongPress: () {
                              setState(() {
                                isMultiSelectMode = true;
                                _selectedIds.add(companyIssueStatus.id);
                              });
                            },
                            onTap: () {
                              if (isMultiSelectMode) {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(companyIssueStatus.id);
                                    if (_selectedIds.isEmpty) {
                                      isMultiSelectMode = false;
                                    }
                                  } else {
                                    _selectedIds.add(companyIssueStatus.id);
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
                                          _selectedIds.add(
                                            companyIssueStatus.id,
                                          );
                                        } else {
                                          _selectedIds.remove(
                                            companyIssueStatus.id,
                                          );
                                          if (_selectedIds.isEmpty) {
                                            isMultiSelectMode = false;
                                          }
                                        }
                                      });
                                    },
                                  )
                                : null,

                            title: Text(
                              companyIssueStatus.companyIssueStatus,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: !isMultiSelectMode
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: companyIssueStatus.status,
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
                                                companyIssueStatus,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      // Switch(
                                      //   value: companyIssueStatus.status,
                                      //   onChanged: (_) =>
                                      //       _toggleAnswerStatus(companyIssueStatus),
                                      //   activeColor: Colors.greenAccent,
                                      //   inactiveThumbColor: Colors.redAccent,
                                      // ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () => _showAddEditDialog(
                                          existing: companyIssueStatus,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_outlined,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _deleteSelected(
                                          ids: [companyIssueStatus.id],
                                          labelForSingle: companyIssueStatus
                                              .companyIssueStatus,
                                        ),
                                      ),
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

  void _showChoiceDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text(
          'Add Custom Issue Status',
          style: TextStyle(color: _accentColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.list, color: _textPrimary),
              title: Text(
                'Select from existing',
                style: TextStyle(color: _textPrimary),
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                // // _showSelectExistingDialog(ctx);
                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const ExistingStatus()),
                );
                if (added == true) {
                  // Navigator.of(context).pop();
                  await _fetchIssueStatuss();
                }
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
                _showAddEditDialog();
              },
            ),
          ],
        ),
      ),
    );
  }
}

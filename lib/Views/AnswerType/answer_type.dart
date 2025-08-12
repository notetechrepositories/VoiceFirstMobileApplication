import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Core/Services/api_client.dart'; // <- your Dio singleton with interceptor
import '../../Models/answer_model.dart';

class ManageAnswerTypePage extends StatefulWidget {
  @override
  State<ManageAnswerTypePage> createState() => _ManageAnswerTypePageState();
}

class _ManageAnswerTypePageState extends State<ManageAnswerTypePage> {
  final Dio _dio = ApiClient().dio;

  List<AnswerTypeModel> _answerTypes = [];
  List<AnswerTypeModel> _filtered = [];
  final Set<String> _selectedIds = {};

  final _searchController = TextEditingController();
  String _statusFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchAnswerTypes();
  }

  Future<void> _fetchAnswerTypes() async {
    try {
      final res = await _dio.get('/answer-type/all');
      if (res.statusCode == 200) {
        final List list = res.data['data'] as List? ?? [];
        setState(() {
          _answerTypes = list.map((e) => AnswerTypeModel.fromJson(e)).toList();
          _applyFilters();
        });
      }
    } on DioException catch (e) {
      debugPrint('AnswerType load error: ${e.response?.data ?? e.message}');
      // Optionally show a snackbar
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _answerTypes.where((item) {
        final matchesText = item.name.toLowerCase().contains(
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

  Future<void> _showAddEditDialog({AnswerTypeModel? existing}) async {
    final controller = TextEditingController(text: existing?.name ?? '');
    final isEditing = existing != null;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            isEditing ? 'Edit Answer Type' : 'Add Answer Type',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter Answer Type Name",
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
                  if (isEditing) {
                    await _dio.put(
                      '/answer-type',
                      data: {
                        'id': existing!.id,
                        'answerTypeName': name,
                        'status': existing.status,
                      },
                    );
                  } else {
                    await _dio.post(
                      '/answer-type',
                      data: {'answerTypeName': name},
                    );
                  }
                  if (mounted) Navigator.pop(ctx);
                  await _fetchAnswerTypes();
                } on DioException catch (e) {
                  final msg =
                      e.response?.data?['message'] ??
                      e.message ??
                      'Save failed';
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                }
              },
              child: Text(isEditing ? 'Save Changes' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleAnswerStatus(AnswerTypeModel answer) async {
    final newStatus = !answer.status;
    try {
      final res = await _dio.patch(
        '/answer-type',
        data: {"id": answer.id, "status": newStatus},
      );
      if (res.statusCode == 200 && (res.data?['isSuccess'] == true)) {
        setState(() {
          answer.status = newStatus; // mutable in your model
          _applyFilters();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Status updated")));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to update status';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Confirm Bulk Delete",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete selected items?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _dio.delete(
        '/answer-type',
        data: _selectedIds.toList(), // backend expects JSON array of IDs
      );

      setState(() {
        _answerTypes.removeWhere((e) => _selectedIds.contains(e.id));
        _selectedIds.clear();
        _applyFilters();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Items deleted")));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Delete failed';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Answer Type'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFFCC737),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
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
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  value: _statusFilter,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
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
            const SizedBox(height: 12),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No Answer Types Found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final answer = _filtered[i];
                        final isSelected = _selectedIds.contains(answer.id);
                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(answer.id);
                                  } else {
                                    _selectedIds.remove(answer.id);
                                  }
                                });
                              },
                            ),
                            title: Text(
                              answer.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: answer.status,
                                  onChanged: (_) => _toggleAnswerStatus(answer),
                                  activeColor: Colors.greenAccent,
                                  inactiveThumbColor: Colors.redAccent,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () =>
                                      _showAddEditDialog(existing: answer),
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
}

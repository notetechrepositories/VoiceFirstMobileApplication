import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/company_answer_type_model.dart';
import 'package:voicefirst/Views/CompanySide/AnswerType/existing_answertype.dart';

class CompanyAnswerType extends StatefulWidget {
  const CompanyAnswerType({super.key});

  @override
  State<CompanyAnswerType> createState() => _CompanyAnswerTypeState();
}

class _CompanyAnswerTypeState extends State<CompanyAnswerType> {
  List<CompanyAnswerTypeModel> _companyAnswerTypes = [];
  List<CompanyAnswerTypeModel> _filtered = [];
  final Set<String> _selectedIds = {};

  final _searchController = TextEditingController();
  String _statusFilter = "All";

  // Page-specific colour palette
  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text

  @override
  void initState() {
    super.initState();
    _fetchCompanyAnswerTypes();
  }

  // Future<void> _fetchAnswerTypes() async {
  //   final res = await http.get(
  //     Uri.parse('${ApiEndpoints.baseUrl}/company-answer-type/all'),
  //   );
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body);
  //     final List list = data['data'];
  //     setState(() {
  //       _answerTypes = list.map((e) => CompanyAnswerTypeModel.fromJson(e)).toList();
  //       _applyFilters();
  //     });
  //   }
  // }
  Future<void> _fetchCompanyAnswerTypes() async {
    final res = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/company-answer-type/all'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list =
          data['data']; // Fetching the data array from the response

      setState(() {
        // Convert each item in the list to a CompanyCompanyAnswerTypeModel instance
        _companyAnswerTypes = list
            .map((e) => CompanyAnswerTypeModel.fromJson(e))
            .toList();
        _applyFilters(); // <-- add this
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _companyAnswerTypes.where((item) {
        final matchesText = item.companyAnswerTypeName.toLowerCase().contains(
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

  Future<void> _showAddEditDialog({CompanyAnswerTypeModel? existing}) async {
    final controller = TextEditingController(
      text: existing?.companyAnswerTypeName ?? '',
    );
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
            decoration: InputDecoration(
              hintText: "Enter Answer Type Name",
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

                final url = Uri.parse(
                  '${ApiEndpoints.baseUrl}/company-answer-type',
                );

                final res = isEditing
                    ? await http.put(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'id': existing.id,
                          'companyAnswerTypeName': name, //  correct key
                          // 'status': existing.status,
                          // keep existing.answerTypeId if your API needs it:
                          // 'answerTypeId': existing.answerTypeId,
                        }),
                      )
                    : await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'companyAnswerTypeName':
                              name, // custom add: only name
                        }),
                      );

                if (res.statusCode == 200 || res.statusCode == 201) {
                  if (context.mounted) Navigator.pop(ctx);
                  await _fetchCompanyAnswerTypes();
                }
              },
              child: Text(isEditing ? 'Save Changes' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleAnswerStatus(CompanyAnswerTypeModel answer) async {
    final newStatus = !answer.status;
    final url = Uri.parse('${ApiEndpoints.baseUrl}/company-answer-type');
    final body = jsonEncode({"id": answer.id, "status": newStatus});

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['isSuccess']) {
        setState(() {
          answer.status = newStatus;
          _applyFilters();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Status updated")));
      }
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Bulk Delete"),
        content: Text("Are you sure you want to delete selected items?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: Text("Delete"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final url = Uri.parse('${ApiEndpoints.baseUrl}/company-answer-type');
    final res = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_selectedIds.toList()),
    );

    if (res.statusCode == 200) {
      setState(() {
        _companyAnswerTypes.removeWhere((e) => _selectedIds.contains(e.id));
        _selectedIds.clear();
        _applyFilters();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Items deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Manage Answer Type'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: _deleteSelected,
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
            const SizedBox(height: 12),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
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
                              answer.companyAnswerTypeName,
                              style: TextStyle(color: Colors.white),
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
                                  icon: Icon(Icons.edit, color: Colors.amber),
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

  void _showChoiceDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text(
          'Add Custom AnswerType',
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
                  MaterialPageRoute(builder: (_) => const ExistingAnswertype()),
                );
                if (added == true) {
                  // Navigator.of(context).pop();
                  await _fetchCompanyAnswerTypes();
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

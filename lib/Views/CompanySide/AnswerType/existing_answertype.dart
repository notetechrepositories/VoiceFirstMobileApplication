import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/answer_model.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';

class ExistingAnswertype extends StatefulWidget {
  const ExistingAnswertype({super.key});

  @override
  State<ExistingAnswertype> createState() => _ExistingAnswertypeState();
}

class _ExistingAnswertypeState extends State<ExistingAnswertype> {
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

  // Future<void> _fetchAnswerTypes() async {
  //   final res = await http.get(
  //     Uri.parse('${ApiEndpoints.baseUrl}/answer-type/all'),
  //   );
  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body);
  //     final List list = data['data'];
  //     setState(() {
  //       _answerTypes = list.map((e) => AnswerTypeModel.fromJson(e)).toList();
  //       _applyFilters();
  //       setState(() {});
  //     });
  //   }
  // }

  Future<void> _fetchAnswerTypes() async {
    final res = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/answer-type/all'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['data'];

      final all = list.map((e) => AnswerTypeModel.fromJson(e)).toList();

      setState(() {
        _answerTypes = all
            .where((e) => e.status == true)
            .toList(); //  active only
        _applyFilters(); // your existing search filter still works
      });
    }
  }

  Future<void> _addtoAnswertype(AnswerTypeModel item) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/company-answer-type');
    final res = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({
        'answerTypeId': item.id,
        'companyAnswerTypeName': item.name,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (!mounted) return;
      SnackbarHelper.showSuccess('Added to company answer types');
      debugPrint('${res.statusCode}');
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      SnackbarHelper.showError('failed to add this item!!');
      debugPrint('${res.statusCode}');
      debugPrint('${res}');
    }
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase();
    _filtered = _answerTypes.where((item) {
      if (!item.status) return false;
      final matchesText = item.name.toLowerCase().contains(q);
      return matchesText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('Select Answer Type'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(_applyFilters),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search active types…",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filtered.isEmpty
          ? const Center(
              child: Text(
                'No active answer types',
                style: TextStyle(color: Colors.white60),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final a = _filtered[i];
                return Card(
                  color: const Color(0xFF1F1F1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      a.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(Icons.add, color: Colors.white70),
                    onTap: () => _addtoAnswertype(a), //  tap to add
                  ),
                );
              },
            ),
    );
  }
}

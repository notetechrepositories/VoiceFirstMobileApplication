import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
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
  // String _statusFilter = "All";

  final Dio _dio = ApiClient().dio;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchAnswerTypes();
  // }

  Future<void> _fetchAnswerTypes() async {
    try {
      final res = await _dio.get('/answer-type/all');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final List list = (res.data['data'] as List?) ?? [];
        final all = list
            .map(
              (e) =>
                  AnswerTypeModel.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList();
        setState(() {
          _answerTypes = all
              .where((e) => e.status == true)
              .toList(); //  active only
          _applyFilters(); // your existing search filter still works
        });
      } else {
        final msg = (res.data is Map && res.data['message'] is String)
            ? res.data['message'] as String
            : 'Failed to load answer types';
        SnackbarHelper.showError(msg);
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'request failed');
      SnackbarHelper.showError(msg);
    }
  }

  Future<void> _addtoAnswertype(AnswerTypeModel item) async {
    try {
      final res = await _dio.post(
        '/company-answer-type',
        data: {'answerTypeId': item.id, 'companyAnswerTypeName': item.name},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data is Map && res.data['isSuccess'] == true) {
          if (!mounted) return;
          setState(() {
            _selectedIds.add(item.id); // mark this item as added
            _applyFilters();
          });
          SnackbarHelper.showSuccess('Added to company answer types');
          debugPrint('${res.statusCode}');
          // Navigator.pop(context, true);
        } else {
          final msg = (res.data is Map && res.data['message'] is String)
              ? res.data['message'] as String
              : 'Failed to add this item';
          if (!mounted) return;
          SnackbarHelper.showError(msg);
          debugPrint('${res.statusCode}');
          debugPrint('$res');
        }
      } else {
        final msg = (res.data is Map && res.data['message'] is String)
            ? res.data['message'] as String
            : 'Request failed';
        if (!mounted) return;
        SnackbarHelper.showError(msg);
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      if (!mounted) return;
      SnackbarHelper.showError('Failed to add this item: $msg');
    }
  }

  Future<void> _loadAlreadyAddedIds() async {
    try {
      // adjust path if your API differs
      final res = await _dio.get('/company-answer-type/all');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final List list = (res.data['data'] as List?) ?? [];
        setState(() {
          _selectedIds
            ..clear()
            ..addAll(
              list.map((e) {
                final m = (e as Map).cast<String, dynamic>();
                // prefer answerTypeId if present; else fallback to id
                return (m['answerTypeId'] ?? m['id']).toString();
              }),
            );
          _applyFilters(); // keep filtered list in sync
        });
      }
    } catch (_) {
      /* ignore */
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
  void initState() {
    super.initState();
    _fetchAnswerTypes();
    _loadAlreadyAddedIds(); // NEW: seed disabled set from server
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: () => Navigator.pop(context, _selectedIds.isNotEmpty),
        ),
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
                final isAdded = _selectedIds.contains(a.id);
                return Card(
                  color: const Color(0xFF1F1F1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      a.name,
                      style:  TextStyle(color: isAdded ? Colors.white38 : Colors.white,), // NEW),
                    ),
                    trailing: isAdded
                        ? const Icon(Icons.check, color: Colors.greenAccent)
                        : const Icon(Icons.add, color: Colors.white70),
                    onTap: isAdded
                        ? null
                        : () => _addtoAnswertype(a), //  tap to add
                  ),
                );
              },
            ),
    );
  }
}

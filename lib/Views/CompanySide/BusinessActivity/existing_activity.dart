import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
import 'package:voicefirst/Models/business_activity_model1.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';

class ExistingActivityScreen extends StatefulWidget {
  const ExistingActivityScreen({super.key});

  @override
  State<ExistingActivityScreen> createState() => _ExistingActivityScreenState();
}

class _ExistingActivityScreenState extends State<ExistingActivityScreen> {
  final Dio _dio = ApiClient().dio;

  final _searchController = TextEditingController();
  List<BusinessActivity> _all = [];
  List<BusinessActivity> _filtered = [];
  final Set<String> _alreadyAdded = {};

  @override
  void initState() {
    super.initState();
    _fetchExisting();
    _loadAlreadyAddedIds();
  }

  Future<void> _fetchExisting() async {
    try {
      final res = await _dio.get('/business-activities/all/active');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final List list = (res.data['data'] as List?) ?? [];
        final parsed = list
            .map(
              (e) =>
                  BusinessActivity.fromJson((e as Map).cast<String, dynamic>()),
            )
            .where((e) => e.status == true) // active only
            .toList();
        setState(() {
          _all = parsed;
          _applyFilters();
        });
      } else {
        SnackbarHelper.showError(
          _messageFrom(res.data) ?? 'Failed to load existing activities',
        );
      }
    } on DioException catch (e) {
      SnackbarHelper.showError(_dioErr(e));
    }
  }

  Future<void> _loadAlreadyAddedIds() async {
    try {
      final res = await _dio.get('/company-business-activity/all');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final List list = (res.data['data'] as List?) ?? [];
        setState(() {
          _alreadyAdded
            ..clear()
            ..addAll(list.map((e) => ((e as Map)['id']).toString()));
          _applyFilters();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _addExistingToCompany(BusinessActivity item) async {
    try {
      final res = await _dio.post(
        '/company-business-activities',
        data: {'existingActivityId': item.id},
      );
      if (_ok(res)) {
        setState(() {
          _alreadyAdded.add(item.id);
          _applyFilters();
        });
        SnackbarHelper.showSuccess('Added to company activities');
      } else {
        SnackbarHelper.showError(_messageFrom(res.data) ?? 'Failed to add');
      }
    } on DioException catch (e) {
      SnackbarHelper.showError(_dioErr(e));
    }
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _all
          .where((a) => a.activityName.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: () => Navigator.pop(context, _alreadyAdded.isNotEmpty),
        ),
        title: const Text('Select Existing Activity'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search active activities…',
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
                'No active activities',
                style: TextStyle(color: Colors.white60),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final a = _filtered[i];
                final isAdded = _alreadyAdded.contains(a.id);
                return Card(
                  color: const Color(0xFF1F1F1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      a.activityName,
                      style: TextStyle(
                        color: isAdded ? Colors.white38 : Colors.white,
                      ),
                    ),
                    trailing: isAdded
                        ? const Icon(Icons.check, color: Colors.greenAccent)
                        : const Icon(Icons.add, color: Colors.white70),
                    onTap: isAdded ? null : () => _addExistingToCompany(a),
                  ),
                );
              },
            ),
    );
  }

  bool _ok(Response res) =>
      (res.statusCode == 200 || res.statusCode == 201) &&
      (res.data is Map && (res.data['isSuccess'] == true));
  String? _messageFrom(dynamic data) =>
      (data is Map && data['message'] is String)
      ? data['message'] as String
      : null;
  String _dioErr(DioException e) =>
      (e.response?.data is Map && e.response!.data['message'] is String)
      ? e.response!.data['message'] as String
      : (e.message ?? 'Request failed');
}

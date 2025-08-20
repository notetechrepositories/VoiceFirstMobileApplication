import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../Core/Services/api_client.dart';
import '../../../Models/media_type.dart'; // <- your Dio singleton with interceptor

class ManageMediaTypePage extends StatefulWidget {
  @override
  State<ManageMediaTypePage> createState() => _ManageMediaTypePageState();
}

class _ManageMediaTypePageState extends State<ManageMediaTypePage> {
  final Dio _dio = ApiClient().dio;

  List<MediaTypeModel> _mediaTypes = [];
  List<MediaTypeModel> _filtered = [];
  final Set<String> _selectedIds = {};

  final _searchController = TextEditingController();
  String _statusFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchMediaTypes();
  }

  Future<void> _fetchMediaTypes() async {
    try {
      final res = await _dio.get('http://59.94.176.2:8022/api/media-type');
      if (res.statusCode == 200) {
        final List list = res.data['data'] as List? ?? [];
        setState(() {
          _mediaTypes = list.map((e) => MediaTypeModel.fromJson(e)).toList();
          _applyFilters();
        });
      }
    } on DioException catch (e) {
      debugPrint('MediaType load error: ${e.response?.data ?? e.message}');
      // Optionally show a snackbar
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _mediaTypes.where((item) {
        final matchesText = item.description.toLowerCase().contains(
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

  Future<void> _showAddEditDialog({MediaTypeModel? existing}) async {
    final controller = TextEditingController(text: existing?.description ?? '');
    final isEditing = existing != null;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            isEditing ? 'Edit Media Type' : 'Add Media Type',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter Media Type Description",
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
                final description = controller.text.trim();
                if (description.isEmpty) return;

                try {
                  if (isEditing) {
                    await _dio.put(
                      '/media-type',
                      data: {
                        'id': existing!.id,
                        'description': description,
                        'status': existing.status,
                      },
                    );
                  } else {
                    await _dio.post(
                      '/media-type',
                      data: {'description': description},
                    );
                  }
                  if (mounted) Navigator.pop(ctx);
                  await _fetchMediaTypes();
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

  Future<void> _toggleMediaStatus(MediaTypeModel media) async {
    final newStatus = !media.status;
    try {
      final res = await _dio.patch(
        '/media-type',
        data: {"id": media.id, "status": newStatus},
      );
      if (res.statusCode == 200 && (res.data?['isSuccess'] == true)) {
        setState(() {
          media.status = newStatus; // mutable in your model
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Media Type'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMediaTypes,
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
                        'No Media Types Found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final media = _filtered[i];
                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            title: Text(
                              media.description,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: media.status,
                                  onChanged: (_) => _toggleMediaStatus(media),
                                  activeColor: Colors.greenAccent,
                                  inactiveThumbColor: Colors.redAccent,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () =>
                                      _showAddEditDialog(existing: media),
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

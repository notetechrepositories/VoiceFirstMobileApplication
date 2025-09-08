import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../Core/Services/api_client.dart'; // Dio singleton with interceptor
import '../../../Models/company_media_type.dart';
import '../../../Models/media_type.dart';

class ManageCompanyMediaTypePage extends StatefulWidget {
  const ManageCompanyMediaTypePage({super.key});

  @override
  State<ManageCompanyMediaTypePage> createState() =>
      _ManageCompanyMediaTypePageState();
}

class _ManageCompanyMediaTypePageState
    extends State<ManageCompanyMediaTypePage> {
  final Dio _dio = ApiClient().dio;

  List<CompanyMediaTypeModel> _companyMediaTypes = [];
  List<MediaTypeModel> _existingMediaTypes = [];
  List<CompanyMediaTypeModel> _filtered = [];
  final _selectedExistingIds = <String>{}; // only used inside "Select existing"

  final _searchController = TextEditingController();
  String _statusFilter = "All";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() => _loading = true);
    await Future.wait([_fetchCompanyMediaTypes(), _fetchExistingMediaTypes()]);
    _applyFilters();
    if (mounted) setState(() => _loading = false);
  }

  // GET /company-media-type
  Future<void> _fetchCompanyMediaTypes() async {
    try {
      final res = await _dio.get(
        '/company-media-type',
        options: Options(extra: {'auth': 'company'}),
      );
      if (res.statusCode == 200) {
        final List list = res.data is Map
            ? (res.data['data'] as List? ?? [])
            : const [];
        setState(() {
          _companyMediaTypes = list
              .map((e) => CompanyMediaTypeModel.fromJson(e))
              .toList();
        });
      } else {
        debugPrint('Company media types fetch failed: ${res.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        'Company media types load error: ${e.response?.data ?? e.message}',
      );
    }
  }

  // GET /media-type (admin-created list to select from)
  Future<void> _fetchExistingMediaTypes() async {
    try {
      final res = await _dio.get(
        '/media-type',
        options: Options(extra: {'auth': 'company'}),
      );
      if (res.statusCode == 200) {
        final List list = res.data is Map
            ? (res.data['data'] as List? ?? [])
            : const [];
        setState(() {
          _existingMediaTypes = list
              .map((e) => MediaTypeModel.fromJson(e))
              .toList();
        });
      } else {
        debugPrint('Existing media types fetch failed: ${res.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        'Existing media types load error: ${e.response?.data ?? e.message}',
      );
    }
  }

  void _applyFilters() {
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _companyMediaTypes.where((item) {
      final desc = (item.companyDescription ?? '').toLowerCase();
      final matchesText = q.isEmpty || desc.contains(q);
      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && item.status == true) ||
          (_statusFilter == 'Inactive' && item.status == false);
      return matchesText && matchesStatus;
    }).toList();
    setState(() => _filtered = filtered);
  }

  bool _alreadyAttached(String mediaTypeId) {
    return _companyMediaTypes.any((c) => (c.mediaTypeId ?? '') == mediaTypeId);
  }

  // POST /company-media-type (attach EXISTING admin media type)
  Future<void> _attachExisting(
    String mediaTypeId, {
    String? companyDescription,
  }) async {
    if (mediaTypeId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid Media Type ID.')));
      return;
    }
    if (_alreadyAttached(mediaTypeId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This media type is already added.')),
      );
      return;
    }
    try {
      final payload = <String, dynamic>{
        'mediaTypeId': mediaTypeId,
        // Use provided companyDescription; fallback to the admin description if we can find it.
        'companyDescription':
            companyDescription ??
            (_existingMediaTypes
                .firstWhere(
                  (m) => m.id == mediaTypeId,
                  orElse: () => MediaTypeModel(
                    id: mediaTypeId,
                    description: '',
                    status: true,
                  ),
                )
                .description),
      };

      final res = await _dio.post(
        '/company-media-type',
        data: payload,
        options: Options(extra: {'auth': 'company'}),
      );

      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['isSuccess'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Media type attached.')));
        await _fetchCompanyMediaTypes();
        _applyFilters();
      } else {
        final msg =
            (res.data is Map ? res.data['message'] : null) ??
            'Failed to attach media type';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      // Guard against string bodies (prevents String['key'] -> _TypeError)
      final msg =
          (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : e.message ?? 'Failed to attach media type';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // POST /company-media-type (create company-only entry, NO mediaTypeId)
  Future<void> _createCompanyCustom(String description) async {
    if (description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }
    try {
      // NOTE: do NOT send mediaTypeId here, server accepts company-only entries
      final res = await _dio.post(
        '/company-media-type',
        data: {'companyDescription': description.trim()},
        options: Options(extra: {'auth': 'company'}),
      );

      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['isSuccess'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Media type added.')));
        await _fetchCompanyMediaTypes();
        _applyFilters();
      } else {
        final msg =
            (res.data is Map ? res.data['message'] : null) ??
            'Failed to add media type';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : e.message ?? 'Failed to add media type';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // PUT /company-media-type  { id, companyDescription }
  Future<void> _updateCompanyMediaType(String id, String newDescription) async {
    try {
      final res = await _dio.put(
        '/company-media-type',
        data: {'id': id, 'companyDescription': newDescription.trim()},
        options: Options(extra: {'auth': 'company'}),
      );
      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['isSuccess'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Media type updated.')));
        await _fetchCompanyMediaTypes();
        _applyFilters();
      } else {
        final msg =
            (res.data is Map ? res.data['message'] : null) ??
            'Failed to update';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : e.message ?? 'Failed to update';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // DELETE /company-media-type   body: ["id1","id2",...]
  Future<void> _deleteCompanyMediaTypes(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final res = await _dio.delete(
        '/company-media-type',
        data: ids,
        options: Options(extra: {'auth': 'company'}),
      );
      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['isSuccess'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted successfully.')));
        await _fetchCompanyMediaTypes();
        _applyFilters();
      } else {
        final msg =
            (res.data is Map ? res.data['message'] : null) ??
            'Failed to delete';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : e.message ?? 'Failed to delete';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ====== UI dialogs ======

  void _showChoiceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add Media Type',
          style: TextStyle(color: Colors.amber),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text(
                'Select from Existing',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSelectExistingDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.create, color: Colors.white),
              title: const Text(
                'Add New',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddNewDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectExistingDialog() {
    final descCtrl = TextEditingController();
    _selectedExistingIds.clear();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select Media Type',
            style: TextStyle(color: Colors.amber),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // optional custom company description
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Company Description (optional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    itemCount: _existingMediaTypes.length,
                    itemBuilder: (_, i) {
                      final e = _existingMediaTypes[i];
                      final selected = _selectedExistingIds.contains(e.id);
                      return ListTile(
                        leading: Checkbox(
                          value: selected,
                          onChanged: (v) {
                            setSt(() {
                              _selectedExistingIds.clear(); // single-select
                              if (v == true) _selectedExistingIds.add(e.id);
                            });
                          },
                        ),
                        title: Text(
                          e.description,
                          style: const TextStyle(color: Colors.white),
                        ),
                        // subtitle: Text(
                        //   'ID: ${e.id}',
                        //   style: const TextStyle(color: Colors.white54),
                        // ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCC737),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (_selectedExistingIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select one media type.')),
                  );
                  return;
                }
                final id = _selectedExistingIds.first;
                if (_alreadyAttached(id)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This media type is already added.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await _attachExisting(
                  id,
                  companyDescription: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNewDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add New Media Type (Company)',
          style: TextStyle(color: Colors.amber),
        ),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCC737),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final desc = ctrl.text.trim();
              Navigator.pop(context);
              await _createCompanyCustom(desc);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(CompanyMediaTypeModel item) {
    final ctrl = TextEditingController(text: item.companyDescription ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Company Media Type',
          style: TextStyle(color: Colors.amber),
        ),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCC737),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final newDesc = ctrl.text.trim();
              Navigator.pop(context);
              await _updateCompanyMediaType(item.id, newDesc);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete', style: TextStyle(color: Colors.amber)),
        content: const Text(
          'Are you sure you want to delete this media type?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCC737),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _deleteCompanyMediaTypes([id]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Media Types'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(),
                  )
                : const Icon(Icons.refresh),
            onPressed: _loading ? null : _refreshAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showChoiceDialog,
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
                  items: const ['All', 'Active', 'Inactive']
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
                              media.companyDescription ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                            // subtitle: Text(
                            //   'ID: ${media.id}${media.mediaTypeId != null ? '  |  mediaTypeId: ${media.mediaTypeId}' : ''}',
                            //   style: const TextStyle(color: Colors.white54),
                            // ),
                            trailing: Wrap(
                              spacing: 0,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () => _showEditDialog(media),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _confirmDelete(media.id),
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

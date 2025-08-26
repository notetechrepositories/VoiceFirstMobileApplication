import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../Core/Services/api_client.dart'; // Dio singleton with interceptor
import '../../../Models/company_media_type.dart';
import '../../../Models/media_type.dart'; // Model for Media Type

class ManageCompanyMediaTypePage extends StatefulWidget {
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
  final Set<String> _selectedIds = {}; // Track selected IDs

  final _searchController = TextEditingController();
  String _statusFilter = "All"; // Filter based on status
  final _companyDescriptionController =
      TextEditingController(); // For description

  @override
  void initState() {
    super.initState();
    _fetchCompanyMediaTypes(); // Load media types for the company
    _fetchExistingMediaTypes(); // Fetch existing media types created by the admin
  }

  // Fetch media types for the company (media types created by the company)
  Future<void> _fetchCompanyMediaTypes() async {
    try {
      final res = await _dio.get(
        '/company-media-type', // Adjusted to match the correct API path
        options: Options(extra: {'auth': 'company'}),
      );
      if (res.statusCode == 200) {
        final List list = res.data['data'] as List? ?? [];
        debugPrint(
          'Fetched company media types: $list',
        ); // Add this log to inspect the response
        setState(() {
          _companyMediaTypes = list.map((e) {
            return CompanyMediaTypeModel.fromJson(
              e,
            ); // Safe parsing with the model
          }).toList();
        });
      } else {
        debugPrint(
          'Error: Failed to fetch media types with status code: ${res.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error loading media types: ${e.response?.data ?? e.message}');
    }
  }

  // Fetch existing media types (media types created by the admin)
  Future<void> _fetchExistingMediaTypes() async {
    try {
      final res = await _dio.get(
        '/media-type', // Assuming this endpoint fetches admin-created media types
        options: Options(extra: {'auth': 'company'}),
      );
      if (res.statusCode == 200) {
        final List list = res.data['data'] as List? ?? [];
        setState(() {
          _existingMediaTypes = list
              .map((e) => MediaTypeModel.fromJson(e))
              .toList();
        });
      }
    } on DioException catch (e) {
      debugPrint(
        'Existing Media Type load error: ${e.response?.data ?? e.message}',
      );
    }
  }

  // Apply filters for media types
  void _applyFilters() {
    setState(() {
      _filtered = _companyMediaTypes.where((item) {
        final matchesText = item.companyDescription.toLowerCase().contains(
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

  // Action for selecting media type
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // Handle adding a new media type for the company
  Future<void> _addCompanyMediaType() async {
    if (_selectedIds.isEmpty || _companyDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a media type and add a description"),
        ),
      );
      return;
    }

    try {
      final mediaTypeId =
          _selectedIds.first; // Assume the company selects only one media type
      final companyDescription = _companyDescriptionController.text.trim();

      // POST request to create the new media type for the company
      final res = await _dio.post(
        '/company-media-type',
        data: {
          "mediaTypeId": mediaTypeId,
          "companyDescription": companyDescription,
        },
      );

      if (res.statusCode == 200 && res.data['isSuccess']) {
        // Successfully added the media type for the company
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Media Type added successfully for the company"),
          ),
        );
        await _fetchCompanyMediaTypes(); // Refresh the media types
      } else {
        // Failed to create the media type
        final msg = res.data['message'] ?? 'Failed to add media type';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to add media type';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // Show the dialog for choosing between adding new or selecting existing media type
  void _showChoiceDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
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
                Navigator.pop(ctx);
                _showSelectExistingDialog(ctx); // Show the existing media types
              },
            ),
            ListTile(
              leading: const Icon(Icons.create, color: Colors.white),
              title: const Text(
                'Add New',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showAddNewDialog(
                  ctx,
                ); // Show the dialog to add a new media type
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show the dialog to select an existing media type
  void _showSelectExistingDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Select Media Type',
          style: TextStyle(color: Colors.amber),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: _existingMediaTypes
                .map(
                  (e) => ListTile(
                    title: Text(
                      e.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIds.add(e.id);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // Show the dialog to add a new media type
  void _showAddNewDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add New Media Type',
          style: TextStyle(color: Colors.amber),
        ),
        content: Column(
          children: [
            TextField(
              controller: _companyDescriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _addCompanyMediaType(); // Add the media type
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.amber,
              ),
              child: const Text('Add Media Type'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Media Types'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChoiceDialog(context),
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
                              media.companyDescription,
                              style: const TextStyle(color: Colors.white),
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

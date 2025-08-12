import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Core/Services/api_client.dart';
import '../../Models/issue_type_model.dart';
import 'add_issue_type.dart';

class ManageIssueTypeScreen extends StatefulWidget {
  const ManageIssueTypeScreen({super.key});

  @override
  State<ManageIssueTypeScreen> createState() => _ManageIssueTypeScreenState();
}

class _ManageIssueTypeScreenState extends State<ManageIssueTypeScreen> {
  final Dio _dio = ApiClient().dio;

  List<IssueType> issueTypes = [];
  bool isLoading = true;
  String errorMessage = '';

  String searchQuery = '';
  String statusFilter = 'All Status';

  @override
  void initState() {
    super.initState();
    fetchIssueTypes();
  }

  Future<void> fetchIssueTypes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final res = await _dio.get('/issue-type/all');
      if (res.statusCode == 200 &&
          res.data is Map<String, dynamic> &&
          res.data['isSuccess'] == true &&
          res.data['data'] != null) {
        final List<dynamic> dataList = res.data['data'];
        setState(() {
          issueTypes = dataList.map((e) => IssueType.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Invalid API response');
      }
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load issue types: ${e.response?.data?['message'] ?? e.message}';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load issue types: $e';
      });
    }
  }

  List<IssueType> get _filtered {
    return issueTypes.where((it) {
      final matchesText = it.issueType.toLowerCase().contains(searchQuery);
      final matchesStatus =
          statusFilter == 'All Status' ||
          (statusFilter == 'Active' && it.status) ||
          (statusFilter == 'Inactive' && !it.status);
      return matchesText && matchesStatus;
    }).toList();
  }

  void _showIssueDetailPopup(IssueType issue) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Issue Type Details",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${issue.issueType}"),
                const SizedBox(height: 8),
                Text("Status: ${issue.status ? 'Active' : 'Inactive'}"),
                const SizedBox(height: 8),
                Text(
                  "Answers: ${issue.issueAnswerTypes.map((e) => e.answerTypeName).join(', ')}",
                ),
                const SizedBox(height: 8),
                Text("Media Required: ${issue.mediaRequired.length} item(s)"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCC737),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddIssueTypePage(existingIssue: issue.toJson()),
                ),
              );
              if (result == true) {
                fetchIssueTypes();
              }
            },
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
        ? Center(child: Text(errorMessage))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) {
                          setState(() => searchQuery = v.trim().toLowerCase());
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: statusFilter,
                      items: const ["All Status", "Active", "Inactive"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => statusFilter = val ?? 'All Status'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No Issue Types Found'))
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 0),
                        itemBuilder: (context, index) {
                          final issue = _filtered[index];
                          return ListTile(
                            leading: const Checkbox(
                              value: false,
                              onChanged: null,
                            ),
                            title: Text(issue.issueType),
                            subtitle: Text(
                              issue.issueAnswerTypes
                                  .map((e) => e.answerTypeName)
                                  .join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () => _showIssueDetailPopup(issue),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: issue.status
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    issue.status ? 'Active' : 'Inactive',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Issue Type'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchIssueTypes,
        child: body is Widget ? body : const SizedBox.shrink(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFCC737),
        foregroundColor: Colors.black,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddIssueTypePage()),
          );
          if (result == true) {
            fetchIssueTypes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Core/Constants/api_endpoins.dart';
import '../../Models/issue_type_model.dart';
import 'add_issue_type.dart';

class ManageIssueTypeScreen extends StatefulWidget {
  const ManageIssueTypeScreen({super.key});

  @override
  State<ManageIssueTypeScreen> createState() => _ManageIssueTypeScreenState();
}

class _ManageIssueTypeScreenState extends State<ManageIssueTypeScreen> {
  List<IssueType> issueTypes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchIssueTypes();
  }

  Future<void> fetchIssueTypes() async {
    final url = Uri.parse(("${ApiEndpoints.baseUrl}/issue-type/all"));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);

        if (jsonBody['isSuccess'] == true && jsonBody['data'] != null) {
          final List<dynamic> dataList = jsonBody['data'];

          setState(() {
            issueTypes = dataList.map((e) => IssueType.fromJson(e)).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid API response');
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load issue types: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Issue Type'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: "All Status",
                        items: const ["All Status", "Active", "Inactive"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: issueTypes.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final issue = issueTypes[index];
                      return ListTile(
                        leading: Checkbox(value: false, onChanged: (_) {}),
                        title: Text(issue.issueType),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: issue.status ? Colors.green : Colors.red,
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
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddIssueTypePage()),
          );

          // If result is true, refresh the list
          if (result == true) {
            fetchIssueTypes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

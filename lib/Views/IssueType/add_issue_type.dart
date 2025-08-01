import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Core/Constants/api_endpoins.dart';

class AddIssueTypePage extends StatefulWidget {
  const AddIssueTypePage({super.key});

  @override
  State<AddIssueTypePage> createState() => _AddIssueTypePageState();
}

class _AddIssueTypePageState extends State<AddIssueTypePage> {
  final _issueTypeController = TextEditingController();
  final _newAnswerTypeController = TextEditingController();

  List<dynamic> answerTypes = [];
  List<String> selectedAnswerTypeIds = [];

  List<dynamic> attachmentTypes = [];
  List<String> selectedAttachmentTypes = [];

  List<dynamic> mediaTypes = [];
  Map<String, Map<String, dynamic>> mediaData = {};

  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final answerRes = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/answer-type'),
      );
      final attachRes = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/attachment-type'),
      );
      final mediaRes = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/media-type'),
      );

      if (answerRes.statusCode == 200 &&
          attachRes.statusCode == 200 &&
          mediaRes.statusCode == 200) {
        setState(() {
          answerTypes = jsonDecode(answerRes.body)['data'];
          attachmentTypes = jsonDecode(attachRes.body)['data'];
          mediaTypes = jsonDecode(mediaRes.body)['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  void _toggleAttachmentType(String id) {
    setState(() {
      if (selectedAttachmentTypes.contains(id)) {
        selectedAttachmentTypes.remove(id);
        mediaData.remove(id);
      } else {
        selectedAttachmentTypes.add(id);
        mediaData[id] = {'max': '', 'maxSize': '', 'media': []};
      }
    });
  }

  Future<void> _addNewAnswerType() async {
    _newAnswerTypeController.clear();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Answer Type"),
        content: TextField(
          controller: _newAnswerTypeController,
          decoration: const InputDecoration(hintText: "Enter answer type name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _newAnswerTypeController.text.trim();
              if (name.isEmpty) return;
              final res = await http.post(
                Uri.parse('${ApiEndpoints.baseUrl}/answer-type'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({"answerTypeName": name}),
              );
              if (res.statusCode == 200) {
                Navigator.pop(ctx);
                await _loadDropdownData();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final issueType = _issueTypeController.text.trim();

    if (issueType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue Type Name is required')),
      );
      return;
    }

    final filteredAnswerTypeIds = selectedAnswerTypeIds
        .where((id) => id.isNotEmpty)
        .toList();

    List<Map<String, dynamic>> mediaRequiredList = [];

    for (var typeId in selectedAttachmentTypes) {
      final mediaList = mediaData[typeId]?['media'] ?? [];

      if (mediaList.isEmpty) continue;

      final entry = {
        "attachmentTypeId": typeId,
        "maximum": int.tryParse(mediaData[typeId]?['max'] ?? '') ?? 0,
        "maximumSize": int.tryParse(mediaData[typeId]?['maxSize'] ?? '') ?? 0,
        "issueMediaType": mediaList
            .where((e) => e['mediaTypeId'] != null)
            .map(
              (e) => {
                "mediaTypeId": e['mediaTypeId'],
                "mandatory": e['mandatory'] ?? false,
              },
            )
            .toList(),
      };

      // Don't include empty `issueMediaType`
      if ((entry["issueMediaType"] as List).isNotEmpty) {
        mediaRequiredList.add(entry);
      }
    }

    final payload = {
      "issueType": issueType,
      "answerTypeIds": filteredAnswerTypeIds,
      "mediaRequired": mediaRequiredList,
    };

    // Optional: Debug log
    debugPrint("Payload: ${jsonEncode(payload)}");

    final res = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/issue-type'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      final body = jsonDecode(res.body);
      final errorMsg = body['message'] ?? 'Submission Failed';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error.isNotEmpty) return Scaffold(body: Center(child: Text(error)));

    return Scaffold(
      appBar: AppBar(title: const Text("Add Issue Type")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Type Name + Answer Type
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _issueTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Issue Type Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Answer Types"),
                      InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Select Answer Types"),
                            items: answerTypes.map<DropdownMenuItem<String>>((
                              a,
                            ) {
                              return DropdownMenuItem<String>(
                                value: a['id'],
                                child: Text(a['answerTypeName']),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null &&
                                  !selectedAnswerTypeIds.contains(id)) {
                                setState(() => selectedAnswerTypeIds.add(id));
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: selectedAnswerTypeIds.map((id) {
                          final name = answerTypes.firstWhere(
                            (e) => e['id'] == id,
                          )['answerTypeName'];
                          return Chip(
                            label: Text(name),
                            onDeleted: () => setState(
                              () => selectedAnswerTypeIds.remove(id),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: _addNewAnswerType,
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Media Type Options",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("Configure photo/video attachment requirements"),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: attachmentTypes.map((a) {
                return FilterChip(
                  label: Text(a['attachmentType']),
                  selected: selectedAttachmentTypes.contains(a['id']),
                  onSelected: (_) => _toggleAttachmentType(a['id']),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            ...selectedAttachmentTypes.map((id) {
              final label = attachmentTypes.firstWhere(
                (e) => e['id'] == id,
              )['attachmentType'];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$label Attachment',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Max Size (MB)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => mediaData[id]?['maxSize'] = v,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Max Number',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => mediaData[id]?['max'] = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Select Media Type",
                          border: OutlineInputBorder(),
                        ),
                        items: mediaTypes.map<DropdownMenuItem<String>>((m) {
                          return DropdownMenuItem<String>(
                            value: m['id'],
                            child: Text(m['description']),
                          );
                        }).toList(),
                        onChanged: (selectedId) {
                          if (selectedId == null) return;
                          final alreadyExists = mediaData[id]?['media'].any(
                            (item) => item['mediaTypeId'] == selectedId,
                          );
                          if (!alreadyExists) {
                            setState(() {
                              mediaData[id]?['media'].add({
                                "mediaTypeId": selectedId,
                                "mandatory": false,
                              });
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ...mediaData[id]?['media'].map<Widget>((m) {
                        final mediaType = mediaTypes.firstWhere(
                          (e) => e['id'] == m['mediaTypeId'],
                          orElse: () => {'description': 'Unknown'},
                        );
                        return CheckboxListTile(
                          title: Text('Mandatory: ${mediaType['description']}'),
                          value: m['mandatory'],
                          onChanged: (val) {
                            setState(() => m['mandatory'] = val);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

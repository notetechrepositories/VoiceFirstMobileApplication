import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../Core/Services/api_client.dart';

class AddIssueTypePage extends StatefulWidget {
  final Map<String, dynamic>? existingIssue;

  const AddIssueTypePage({super.key, this.existingIssue});

  @override
  State<AddIssueTypePage> createState() => _AddIssueTypePageState();
}

class _AddIssueTypePageState extends State<AddIssueTypePage> {
  final Dio _dio = ApiClient().dio;

  final _issueTypeController = TextEditingController();
  final _newAnswerTypeController = TextEditingController();

  List<dynamic> answerTypes = [];
  List<String> selectedAnswerTypeIds = [];

  List<dynamic> attachmentTypes = [];
  List<String> selectedAttachmentTypes = [];

  List<dynamic> mediaTypes = [];

  /// mediaData[attachmentTypeId] = {
  ///   'max': '3',
  ///   'maxSize': '10',
  ///   'media': [{'mediaTypeId': '...', 'mandatory': true}, ...]
  /// }
  Map<String, Map<String, dynamic>> mediaData = {};

  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadAndInitializeData();
  }

  Future<void> _loadAndInitializeData() async {
    await _loadDropdownData();
    _prepopulateFieldsIfEditing();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final f1 = _dio.get('/answer-type');
      final f2 = _dio.get('/attachment-type');
      final f3 = _dio.get('/media-type');

      final results = await Future.wait([f1, f2, f3]);

      setState(() {
        answerTypes = (results[0].data?['data'] as List?) ?? [];
        attachmentTypes = (results[1].data?['data'] as List?) ?? [];
        mediaTypes = (results[2].data?['data'] as List?) ?? [];
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error =
            'Failed to load data: ${e.response?.data?['message'] ?? e.message}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  void _prepopulateFieldsIfEditing() {
    final issue = widget.existingIssue;
    if (issue == null) return;

    _issueTypeController.text = issue['issueType'] ?? '';

    // Answer types (existing)
    final issueAns = (issue['issueAnswerTypes'] as List?) ?? [];
    selectedAnswerTypeIds = issueAns
        .map((a) => (a['answerTypeId'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    // Attachment types + media details
    final medReq = (issue['mediaRequired'] as List?) ?? [];
    selectedAttachmentTypes = medReq
        .map((m) => (m['attachmentTypeId'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    for (final m in medReq) {
      final attachId = m['attachmentTypeId'];
      mediaData[attachId] = {
        'max': (m['maximum'] ?? '').toString(),
        'maxSize': (m['maximumSize'] ?? '').toString(),
        'media': ((m['issueMediaType'] as List?) ?? []).map((x) {
          return {
            "mediaTypeId": x['mediaTypeId'],
            "mandatory": x['mandatory'] ?? false,
            // keep the id so PUT can send it back if needed
            "issueMediaTypeId": x['issueMediaTypeId'],
          };
        }).toList(),
      };
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
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Add New Answer Type",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _newAnswerTypeController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Enter answer type name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCC737),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final name = _newAnswerTypeController.text.trim();
              if (name.isEmpty) return;
              try {
                final res = await _dio.post(
                  '/answer-type',
                  data: {"answerTypeName": name},
                );
                if (res.statusCode == 200) {
                  Navigator.pop(ctx);
                  await _loadDropdownData();
                }
              } catch (_) {}
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

    final isEditing = widget.existingIssue != null;

    final filteredAnswerTypeIds = selectedAnswerTypeIds
        .where((id) => id.isNotEmpty)
        .toList();

    // Build mediaRequired payload
    final List<Map<String, dynamic>> mediaRequiredList = [];
    for (var typeId in selectedAttachmentTypes) {
      final mediaList = (mediaData[typeId]?['media'] as List?) ?? [];
      if (mediaList.isEmpty) continue;

      final existingMediaRequired = isEditing
          ? ((widget.existingIssue!['mediaRequired'] as List?) ?? [])
                .firstWhere(
                  (m) => m['attachmentTypeId'] == typeId,
                  orElse: () => <String, dynamic>{},
                )
          : <String, dynamic>{};

      mediaRequiredList.add({
        // Only include ID for PUT when it exists
        if (isEditing && (existingMediaRequired['mediaRequiredId'] != null))
          "mediaRequiredId": existingMediaRequired['mediaRequiredId'],
        "attachmentTypeId": typeId,
        "maximum":
            int.tryParse((mediaData[typeId]?['max'] ?? '').toString()) ?? 0,
        "maximumSize":
            int.tryParse((mediaData[typeId]?['maxSize'] ?? '').toString()) ?? 0,
        "issueMediaType": mediaList.map<Map<String, dynamic>>((m) {
          final existingMediaItem =
              ((existingMediaRequired['issueMediaType'] as List?) ?? [])
                  .firstWhere(
                    (x) => x['mediaTypeId'] == m['mediaTypeId'],
                    orElse: () => <String, dynamic>{},
                  );

          return {
            "mediaTypeId": m["mediaTypeId"],
            "mandatory": m["mandatory"] ?? false,
            if (isEditing && (existingMediaItem['issueMediaTypeId'] != null))
              "issueMediaTypeId": existingMediaItem['issueMediaTypeId'],
          };
        }).toList(),
      });
    }

    final body = isEditing
        ? {
            "id": widget.existingIssue!['id'],
            "issueType": issueType,
            "issueAnswerTypes": filteredAnswerTypeIds.map((id) {
              final existingAnswer =
                  ((widget.existingIssue!['issueAnswerTypes'] as List?) ?? [])
                      .firstWhere(
                        (e) => e['answerTypeId'] == id,
                        orElse: () => <String, dynamic>{},
                      );

              return {
                "answerTypeId": id,
                if (existingAnswer['issueAnswerTypeId'] != null)
                  "issueAnswerTypeId": existingAnswer['issueAnswerTypeId'],
              };
            }).toList(),
            "mediaRequired": mediaRequiredList,
          }
        : {
            "issueType": issueType,
            "answerTypeIds": filteredAnswerTypeIds,
            "mediaRequired": mediaRequiredList,
          };

    try {
      final res = isEditing
          ? await _dio.put('/issue-type', data: body)
          : await _dio.post('/issue-type', data: body);

      if (res.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final msg = (res.data is Map && res.data['message'] != null)
            ? res.data['message']
            : 'Submission Failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.data?.toString() ??
          e.message ??
          'Submission Failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error.isNotEmpty) {
      return Scaffold(body: Center(child: Text(error)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingIssue != null ? "Edit Issue Type" : "Add Issue Type",
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Type + AnswerType dropdown
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
                            items: answerTypes
                                .map<DropdownMenuItem<String>>(
                                  (a) => DropdownMenuItem<String>(
                                    value: a['id'],
                                    child: Text(a['answerTypeName']),
                                  ),
                                )
                                .toList(),
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
                            orElse: () => {'answerTypeName': 'Unknown'},
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
                  tooltip: 'Add new answer type',
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Media Type Options",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("Configure attachment requirements"),
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
                orElse: () => {'attachmentType': 'Unknown'},
              )['attachmentType'];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$label Attachment',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: mediaData[id]?['maxSize'] ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Max Size (MB)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => mediaData[id]?['maxSize'] = v,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: mediaData[id]?['max'] ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Max Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => mediaData[id]?['max'] = v,
                                style: const TextStyle(color: Colors.white),
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
                          items: mediaTypes
                              .map<DropdownMenuItem<String>>(
                                (m) => DropdownMenuItem<String>(
                                  value: m['id'],
                                  child: Text(m['description']),
                                ),
                              )
                              .toList(),
                          onChanged: (selectedId) {
                            if (selectedId == null) return;
                            final alreadyExists =
                                (mediaData[id]?['media'] as List).any(
                                  (item) => item['mediaTypeId'] == selectedId,
                                );
                            if (!alreadyExists) {
                              setState(() {
                                (mediaData[id]?['media'] as List).add({
                                  "mediaTypeId": selectedId,
                                  "mandatory": false,
                                });
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        ...((mediaData[id]?['media'] as List).map<Widget>((m) {
                          final mediaType = mediaTypes.firstWhere(
                            (e) => e['id'] == m['mediaTypeId'],
                            orElse: () => {'description': 'Unknown'},
                          );
                          return CheckboxListTile(
                            title: Text(
                              'Mandatory: ${mediaType['description']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: m['mandatory'] == true,
                            onChanged: (val) =>
                                setState(() => m['mandatory'] = val ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xFFFCC737),
                          );
                        })).toList(),
                      ],
                    ),
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
                  backgroundColor: const Color(0xFFFCC737),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.existingIssue != null ? "Update" : "Submit",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Widgets/bread_crumb.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Models/division_three_model.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_view.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div1/div_one_view.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div2/div_two_view.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Widgets/add_division.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Widgets/update_division.dart';

class DivisionThreeView extends StatefulWidget {
  // const DivisionThreeView({super.key});

  final String divisionTwoId;
  // final String divisionLabel;
  final CountryModel country;
  final String divisionOneId;

  const DivisionThreeView({
    super.key,
    required this.divisionTwoId,
    required this.country,
    required this.divisionOneId,
  });

  @override
  State<DivisionThreeView> createState() => _DivisionThreeViewState();
}

class _DivisionThreeViewState extends State<DivisionThreeView> {
  //to accept data passing from country page

  // Page-specific colour palette
  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  // final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text
  // ──────────────────────────────────────

  bool isMultiSelectMode = false;
  Set<String> selectedIds = {};
  bool isDataLoaded = false;

  List<DivisionThreeModel> divisionThreeList = [];
  List<DivisionThreeModel> filteredDivThree = [];
  final query = "";
  final TextEditingController _searchController = TextEditingController();

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      selectedIds.clear();
      if (selectAll) {
        // Select only the currently *visible* (filtered) items.
        selectedIds.addAll(filteredDivThree.map((e) => e.id));
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isMultiSelectMode = false;
      selectedIds.clear();
    });
  }

  void _filterDivisions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredDivThree = List.from(divisionThreeList);
      } else {
        filteredDivThree = divisionThreeList
            .where((div) => div.divisionThree.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Are *all visible* items currently selected?
  bool get _allVisibleSelected =>
      filteredDivThree.isNotEmpty &&
      selectedIds.length == filteredDivThree.length;

  Future<void> getAllDivisionThree() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/division-three/all?divisionTwo=${widget.divisionTwoId}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((e) => DivisionThreeModel.fromJson(e))
            .toList();

        setState(() {
          divisionThreeList = fetched;
          filteredDivThree = List.from(divisionThreeList);
          isDataLoaded = true;
        });
      } else {
        debugPrint('Failed to fetch Division Three: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching Division Three: $e');
    }
  }

  Future<bool> _addDivThree(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-three');
    final body = {"divisionThree": name, "divisionTwoId": widget.divisionTwoId};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getAllDivisionThree(); // Refresh list
        return true;
      } else {
        debugPrint('Failed to add division: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding division: $e');
      return false;
    }
  }

  //deletion
  Future<bool> deleteDivThree(List<String> ids) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-three');

    try {
      final body = jsonEncode(ids);
      debugPrint('Sending body: $body');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['isSuccess'] == true;
      } else {
        debugPrint('Delete failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting division: $e');
      return false;
    }
  }

  //update status
  Future<bool> _updateDivThreeStatus(String id, bool status) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-three');

    final body = {'id': id, 'status': status};

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('Status updated to $status');
        return true;
        // return data['isSuccess'] == true;
      } else if (response.statusCode == 409) {
        // Conflict: activity already exists or similar business rule violation
        _showConflictDialog(); // <-- Call custom dialog
        return false;
      } else {
        debugPrint('Failed to update status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  void _showConflictDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Conflict'),
        content: Text(
          'This activity already exists or conflicts with another entry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  //update divisionThree
  Future<bool> updateDivisionThree({
    required String id,
    required String divisionThree,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-three');
    final body = {"id": id, "divisionThree": divisionThree};

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['isSuccess'] == true;
      } else {
        debugPrint('Update failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception while updating divisionThree: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDivisions);
    getAllDivisionThree();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        iconTheme: IconThemeData(color: _accentColor),
        elevation: 0,
        title: Text(
          isMultiSelectMode
              ? '${selectedIds.length} selected'
              : widget.country.divisionThreeLabel,
          style: TextStyle(color: _textPrimary),
        ),

        actions: isMultiSelectMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text(
                          'Are you sure you want to delete ${selectedIds.length} selected item(s)?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final success = await deleteDivThree(
                        selectedIds.toList(),
                      );
                      if (!mounted) return;
                      if (success) {
                        setState(() {
                          divisionThreeList.removeWhere(
                            (x) => selectedIds.contains(x.id),
                          );
                          filteredDivThree.removeWhere(
                            (x) => selectedIds.contains(x.id),
                          );
                          selectedIds.clear();
                          isMultiSelectMode = false;
                        });

                        SnackbarHelper.showSuccess(
                          'Selected items deleted successfully',
                        );
                        await getAllDivisionThree();
                        if (!mounted) return;
                      } else {
                        SnackbarHelper.showError(
                          'Failed to delete selected divisions',
                        );
                      }
                    }
                  },
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          //breadcrumb
          ArrowBreadcrumb(
            steps: [
              "Country",
              widget.country.divisionOneLabel,
              widget.country.divisionTwoLabel,
              widget.country.divisionThreeLabel,
            ],
            currentIndex: 3,
            onTap: (index) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CountryView()),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Division1View(country: widget.country),
                  ),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DivisionTwoView(
                      country: widget.country,
                      divisionOneId: widget.divisionOneId,
                    ),
                  ),
                );
              }
            },
          ),

          // ----searchbar----
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: _textSecondary),
                prefixIcon: Icon(Icons.search, color: _textSecondary),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: isMultiSelectMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _enterSelectionMode(
                            selectAll: !_allVisibleSelected,
                          ),
                          child: Text(
                            _allVisibleSelected ? 'Clear All' : 'Select All',
                            style: TextStyle(color: _accentColor),
                          ),
                        ),
                        TextButton(
                          onPressed: _exitSelectionMode,
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: _accentColor),
                          ),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: () => _enterSelectionMode(),
                      child: Text(
                        'Select',
                        style: TextStyle(color: _accentColor),
                      ),
                    ),
            ),
          ),

          Expanded(
            child: isDataLoaded
                ? filteredDivThree.isEmpty
                      ? Center(
                          child: Text(
                            'No divisions found',
                            style: TextStyle(color: _textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDivThree.length,
                          itemBuilder: (context, index) {
                            final d = filteredDivThree[index];
                            final isSelected = selectedIds.contains(d.id);

                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  isMultiSelectMode = true;
                                  selectedIds.add(d.id);
                                });
                              },
                              onTap: () {
                                if (isMultiSelectMode) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedIds.remove(d.id);
                                      if (selectedIds.isEmpty) {
                                        isMultiSelectMode = false;
                                      }
                                    } else {
                                      selectedIds.add(d.id);
                                    }
                                  });
                                }
                              },
                              child: Card(
                                elevation: isSelected ? 4 : 1,
                                color: isSelected
                                    ? Colors.grey[800]
                                    : _cardColor,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Icon(
                                      //   Icons.location_city,
                                      //   color: _accentColor,
                                      // ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.divisionThree,
                                              style: TextStyle(
                                                color: _textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                        ),
                                      ),
                                      // ─ Right: Status or Delete/Select ─
                                      if (!isMultiSelectMode) ...[
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: _accentColor,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => EditDivisionDialog(
                                                    title:
                                                        'Edit ${widget.country.divisionOneLabel}',
                                                    initialValue:
                                                        d.divisionThree,
                                                    cardColor: _cardColor,
                                                    textPrimary: _textPrimary,
                                                    textSecondary:
                                                        _textSecondary,
                                                    accentColor: _accentColor,
                                                    onSubmit: (newName) async {
                                                      final success =
                                                          await updateDivisionThree(
                                                            id: d.id,
                                                            divisionThree:
                                                                newName,
                                                          );
                                                      if (success) {
                                                        await getAllDivisionThree();
                                                      }
                                                      return success;
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                            Transform.scale(
                                              scale: 0.7,
                                              child: Switch(
                                                value: d.status,
                                                activeColor: Colors.green,
                                                onChanged: (val) async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          title: Text(
                                                            'Confirm',
                                                          ),
                                                          content: Text(
                                                            'Are you sure you want to ${val ? 'activate' : 'deactivate'} this division?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                              child: Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                              child: Text(
                                                                'Yes',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                  if (confirm == true) {
                                                    final success =
                                                        await _updateDivThreeStatus(
                                                          d.id,
                                                          val,
                                                        );

                                                    if (success) {
                                                      setState(() {
                                                        d.status = val;
                                                      });
                                                      SnackbarHelper.showSuccess(
                                                        'Status Updated',
                                                      );
                                                    } else {
                                                      SnackbarHelper.showError(
                                                        'Failed to update status',
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () async {
                                                final confirm =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                              'Confirm',
                                                            ),
                                                            content: Text(
                                                              'Are you sure you want to delete the division "${d.divisionThree}"?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child: Text(
                                                                  'Cancel',
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                                child: Text(
                                                                  'Yes',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    );

                                                if (confirm == true) {
                                                  final success =
                                                      await deleteDivThree([
                                                        d.id,
                                                      ]);
                                                  if (success) {
                                                    setState(() {
                                                      divisionThreeList
                                                          .removeWhere(
                                                            (x) => x.id == d.id,
                                                          );
                                                      filteredDivThree
                                                          .removeWhere(
                                                            (x) => x.id == d.id,
                                                          );
                                                    });
                                                    SnackbarHelper.showError(
                                                      'Division deleted',
                                                    );
                                                  }
                                                } else {
                                                  SnackbarHelper.showError(
                                                    'Failed to delete division',
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ] else if (isMultiSelectMode)
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                selectedIds.add(d.id);
                                              } else {
                                                selectedIds.remove(d.id);
                                                if (selectedIds.isEmpty) {
                                                  isMultiSelectMode = false;
                                                }
                                              }
                                            });
                                          },
                                          activeColor: _accentColor,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                : Center(
                    child: Text(
                      'No ${widget.country.divisionThreeLabel} to show',
                    ),
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        child: Icon(Icons.add, color: _bgColor),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddDivisionDialog(
              label: widget.country.divisionOneLabel,
              cardColor: _cardColor,
              textPrimary: _textPrimary,
              textSecondary: _textSecondary,
              accentColor: _accentColor,
              onSubmit: _addDivThree,
            ),
          );
        },
      ),
    );
  }
}

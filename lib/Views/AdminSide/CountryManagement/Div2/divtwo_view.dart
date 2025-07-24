import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Models/division_two_model.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div1/add_divisionOne.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div2/add_divtwo_dialog.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div2/edit_div2_dialog.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div3/div_three_view.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Widgets/add_division.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Widgets/update_division.dart';

class DivisionTwoView extends StatefulWidget {
  // const DivisionTwoView({super.key});

  final String divisionOneId;
  final CountryModel country;

  const DivisionTwoView({
    super.key,
    required this.divisionOneId,
    required this.country,
  });

  @override
  State<DivisionTwoView> createState() => _DivisionTwoViewState();
}

class _DivisionTwoViewState extends State<DivisionTwoView> {
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

  List<DivisionTwoModel> divisionTwoList = [];
  List<DivisionTwoModel> filteredDivTwo = [];
  final query = "";
  final TextEditingController _searchController = TextEditingController();

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      selectedIds.clear();
      if (selectAll) {
        // Select only the currently *visible* (filtered) items.
        selectedIds.addAll(filteredDivTwo.map((e) => e.id));
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
        filteredDivTwo = List.from(divisionTwoList);
      } else {
        filteredDivTwo = divisionTwoList
            .where((div) => div.divisionTwo.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Are *all visible* items currently selected?
  bool get _allVisibleSelected =>
      filteredDivTwo.isNotEmpty && selectedIds.length == filteredDivTwo.length;

  Future<void> getAllDivisionTwos() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/division-two/all?divisionOne=${widget.divisionOneId}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((e) => DivisionTwoModel.fromJson(e))
            .toList();

        setState(() {
          divisionTwoList = fetched;
          filteredDivTwo = List.from(divisionTwoList);
          isDataLoaded = true;
        });
      } else {
        debugPrint('Failed to fetch Division Two: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching Division Two: $e');
    }
  }

  Future<bool> _addDivisionTwo(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-two');
    final body = {"divisionTwo": name, "divisionOneId": widget.divisionOneId};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getAllDivisionTwos(); // Refresh list
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
  Future<bool> deleteDivTwo(List<String> ids) async {
    // if (ids.isEmpty) {
    //   debugPrint("❌ No IDs to delete.");
    //   return false;
    // }

    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-two');

    try {
      final body = jsonEncode(ids); // ✅ array like ["id1","id2"]
      print('Sending body: $body');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

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
  Future<bool> _updateDivTwoStatus(String id, bool status) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-two');

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

  //update divisonone
  Future<bool> updateDivisionTwo({
    required String id,
    required String divisionTwo,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-two');
    final body = {"id": id, "divisionTwo": divisionTwo};

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
      debugPrint('Exception while updating divisionTwo: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDivisions);
    getAllDivisionTwos();
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
              : widget
                    .country
                    .divisionTwoLabel, // ✅ Now shows dynamic label like "State", "District"
          style: TextStyle(color: _textSecondary),
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
                      final success = await deleteDivTwo(selectedIds.toList());
                      if (success) {
                        setState(() {
                          divisionTwoList.removeWhere(
                            (x) => selectedIds.contains(x.id),
                          );
                          filteredDivTwo.removeWhere(
                            (x) => selectedIds.contains(x.id),
                          );
                          selectedIds.clear();
                          isMultiSelectMode = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selected divisions deleted successfully',
                            ),
                          ),
                        );

                        await getAllDivisionTwos(); // Optional refresh
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to delete selected divisions',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
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
                ? filteredDivTwo.isEmpty
                      ? Center(
                          child: Text(
                            'No divisions found',
                            style: TextStyle(color: _textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDivTwo.length,
                          itemBuilder: (context, index) {
                            final d = filteredDivTwo[index];
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
                                      if (selectedIds.isEmpty)
                                        isMultiSelectMode = false;
                                    } else {
                                      selectedIds.add(d.id);
                                    }
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DivisionThreeView(
                                        divisionTwoId: d.id,
                                        country: widget.country,
                                      ),
                                    ),
                                  );
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
                                      Icon(
                                        Icons.location_city,
                                        color: _accentColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.divisionTwo,
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
                                                    initialValue: d.divisionTwo,
                                                    cardColor: _cardColor,
                                                    textPrimary: _textPrimary,
                                                    textSecondary:
                                                        _textSecondary,
                                                    accentColor: _accentColor,
                                                    onSubmit: (newName) async {
                                                      final success =
                                                          await updateDivisionTwo(
                                                            id: d.id,
                                                            divisionTwo:
                                                                newName,
                                                          );
                                                      if (success)
                                                        await getAllDivisionTwos(); // ✅ Ensures latest list
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
                                                        await _updateDivTwoStatus(
                                                          d.id,
                                                          val,
                                                        );

                                                    if (success) {
                                                      setState(() {
                                                        d.status = val;
                                                      });
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Status Updated',
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Failed to update status',
                                                          ),
                                                        ),
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
                                                              'Are you sure you want to delete the division "${d.divisionTwo}"?',
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
                                                      await deleteDivTwo([
                                                        d.id,
                                                      ]);
                                                  if (success) {
                                                    setState(() {
                                                      divisionTwoList
                                                          .removeWhere(
                                                            (x) => x.id == d.id,
                                                          );
                                                      filteredDivTwo
                                                          .removeWhere(
                                                            (x) => x.id == d.id,
                                                          );
                                                    });
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Division deleted',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Failed to delete division',
                                                      ),
                                                    ),
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
                                                if (selectedIds.isEmpty)
                                                  isMultiSelectMode = false;
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
                      'No ${widget.country.divisionTwoLabel} to show',
                      style: TextStyle(color: Colors.white),
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
              onSubmit: _addDivisionTwo,
            ),
          );
        },
      ),
    );
  }
}

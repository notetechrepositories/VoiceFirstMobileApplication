import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Models/division_one_model.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div1/add_divisionOne.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div1/update_division_one.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div2/divtwo_view.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Widgets/add_division.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Widgets/update_division.dart';

class Division1View extends StatefulWidget {
  // const Division1View({super.key});

  // final String countryId;
  // final String divisionLabel;

  final CountryModel country;

  const Division1View({
    super.key,
    required this.country,
    // required this.divisionLabel,
  });

  @override
  State<Division1View> createState() => _Division1ViewState();
}

class _Division1ViewState extends State<Division1View> {
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

  List<DivisionOneModel> divisionOneList = [];
  List<DivisionOneModel> filteredDivOne = [];
  final query = "";
  final TextEditingController _searchController = TextEditingController();

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      selectedIds.clear();
      if (selectAll) {
        // Select only the currently *visible* (filtered) items.
        selectedIds.addAll(filteredDivOne.map((e) => e.id));
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
        filteredDivOne = List.from(divisionOneList);
      } else {
        filteredDivOne = divisionOneList
            .where((div) => div.divisionOne.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Are *all visible* items currently selected?
  bool get _allVisibleSelected =>
      filteredDivOne.isNotEmpty && selectedIds.length == filteredDivOne.length;

  Future<void> getAllDivisionOnes() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/division-one/all?country=${widget.country.id}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        final fetched = dataList
            .map((e) => DivisionOneModel.fromJson(e))
            .toList();

        setState(() {
          divisionOneList = fetched;
          filteredDivOne = List.from(divisionOneList);
          isDataLoaded = true;
        });
      } else {
        debugPrint('Failed to fetch Division One: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching Division One: $e');
    }
  }

  Future<bool> _addDivisionOne(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-one');
    final body = {"divisionOne": name, "countryId": widget.country.id};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getAllDivisionOnes(); // Refresh list
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
  Future<bool> deleteDivOne(List<String> ids) async {
    // if (ids.isEmpty) {
    //   debugPrint("❌ No IDs to delete.");
    //   return false;
    // }

    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-one');

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
  Future<bool> _updateDivOneStatus(String id, bool status) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-one');

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

  //update divisonone
  Future<bool> updateDivisionOne({
    required String id,
    required String divisionOne,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/division-one');
    final body = {"id": id, "divisionOne": divisionOne};

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
      debugPrint('Exception while updating divisionOne: $e');
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDivisions);
    getAllDivisionOnes();
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
                    .divisionOneLabel, // ✅ Now shows dynamic label like "State", "District"
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
                      final success = await deleteDivOne(selectedIds.toList());
                      if (success) {
                        setState(() {
                          divisionOneList.removeWhere(
                            (x) => selectedIds.contains(x.id),
                          );
                          filteredDivOne.removeWhere(
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

                        await getAllDivisionOnes(); // Optional refresh
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

                // IconButton(
                //   icon: Icon(Icons.delete, color: Colors.redAccent),
                //   onPressed: () async {
                //     final confirmed = await deleteDivOne(selectedIds.toList());
                //     if (confirmed) {
                //       setState(() {
                //         divisionOneList.removeWhere(
                //           (x) => selectedIds.contains(x.id),
                //         );

                //         getAllDivisionOnes();
                //         selectedIds.clear();
                //         isMultiSelectMode = false;
                //       });
                //     }
                //   },
                // ),
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
                ? filteredDivOne.isEmpty
                      ? Center(
                          child: Text(
                            'No divisions found',
                            style: TextStyle(color: _textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDivOne.length,
                          itemBuilder: (context, index) {
                            final d = filteredDivOne[index];
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
                                  //add redirection to div2
                                  //navigator
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DivisionTwoView(
                                        divisionOneId: d.id,
                                        country: widget.country,
                                      ),
                                    ),
                                  );

                                  // selectedIds.add(d.id);
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
                                              d.divisionOne,
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
                                                    initialValue: d.divisionOne,
                                                    cardColor: _cardColor,
                                                    textPrimary: _textPrimary,
                                                    textSecondary:
                                                        _textSecondary,
                                                    accentColor: _accentColor,
                                                    onSubmit: (newName) async {
                                                      final success =
                                                          await updateDivisionOne(
                                                            id: d.id,
                                                            divisionOne:
                                                                newName,
                                                          );
                                                      if (success)
                                                        await getAllDivisionOnes(); // ✅ Ensures latest list
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
                                                        await _updateDivOneStatus(
                                                          d.id,
                                                          val,
                                                        );

                                                    if (success) {
                                                      setState(() {
                                                        d.status = val;
                                                      });
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
                                                              'Are you sure you want to delete the division "${d.divisionOne}"?',
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
                                                      await deleteDivOne([
                                                        d.id,
                                                      ]);
                                                  if (success) {
                                                    setState(() {
                                                      divisionOneList
                                                          .removeWhere(
                                                            (x) => x.id == d.id,
                                                          );
                                                      filteredDivOne
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 250),
                      child: Text(
                        'No ${widget.country.divisionOneLabel} to show',
                        style: TextStyle(color: Colors.white),
                      ),
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
              onSubmit: _addDivisionOne, // <-- your function in the view
            ),
          );
        },
      ),
    );
  }
}

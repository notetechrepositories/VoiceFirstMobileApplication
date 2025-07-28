import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Widgets/snack_bar.dart';
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_add.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_detail_view.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_edit.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Div1/div_one_view.dart';

class CountryView extends StatefulWidget {
  const CountryView({super.key});

  // final CountryModel country;

  @override
  State<CountryView> createState() => _CountryViewState();
}

class _CountryViewState extends State<CountryView> {
  bool isMultiSelectMode = false;
  Set<String> selectedIds = {};

  void _enterSelectionMode({bool selectAll = false}) {
    setState(() {
      isMultiSelectMode = true;
      selectedIds.clear();
      if (selectAll) {
        // Select only the currently *visible* (filtered) items.
        // selectedIds.addAll(filteredCountries.map((e) => e[id] as String));
        selectedIds.addAll(filteredCountries.map((e) => e.id));
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isMultiSelectMode = false;
      selectedIds.clear();
    });
  }

  /// Are *all visible* items currently selected?
  bool get _allVisibleSelected =>
      filteredCountries.isNotEmpty &&
      selectedIds.length == filteredCountries.length;

  List<CountryModel> countries = [];
  List<CountryModel> filteredCountries = [];
  final query = "";
  final TextEditingController _searchController = TextEditingController();

  // Page-specific colour palette
  final Color _bgColor = Colors.black; // page background
  final Color _cardColor = Color(0xFF262626); // dark grey card
  // final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text
  // ──────────────────────────────────────

  bool isDataLoaded = false;

  Future<void> getallCountries() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country/all');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        //using model
        final fetched = dataList
            .map((countryJson) => CountryModel.fromJson(countryJson))
            .toList();

        setState(() {
          countries = fetched;
          // filteredCountries = List.from(fetched);
          filteredCountries = countries
              .where((c) => c.country.toLowerCase().contains(query))
              .toList();

          isDataLoaded = true;
          print(countries);
        });
      } else {
        debugPrint('failed to fetch countries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception Occured : $e');
    }
  }

  Future<void> _addCountry({
    required String country,
    required String divisionOne,
    required String divisionTwo,
    required String divisionThree,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');
    final body = {
      "country": country,
      "divisionOneLabel": divisionOne,
      "divisionTwoLabel": divisionTwo,
      "divisionThreeLabel": divisionThree,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Country added successfully');
        SnackbarHelper.showError('Country added successfully');
        await getallCountries(); // refresh list
      } else {
        debugPrint('Failed to add country: ${response.statusCode}');
        _showConflictDialog();
        SnackbarHelper.showError('Failed to add country');
      }
    } catch (e) {
      debugPrint('Error: $e');
      _showConflictDialog();
      SnackbarHelper.showError('Something Went Wrong');
    }
  }

  Future<bool> deleteCountries(List<String> id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(id),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['isSuccess'] == true;
      } else {
        debugPrint('delete failed with status:${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting country: $e');
      return false;
    }
  }

  //update status
  Future<bool> _updateCountryStatus(String id, bool status) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

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
      } else if (response.statusCode == 409) {
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

  Future<Map<String, dynamic>?> updateCountry({
    required String id,
    String? country,
    String? divisionOneLabel,
    String? divisionTwoLabel,
    String? divisionThreeLabel,
  }) async {
    final Map<String, dynamic> body = {'id': id};

    if (country != null && country.isNotEmpty) {
      body['country'] = country;
    }
    if (divisionOneLabel != null && divisionOneLabel.isNotEmpty) {
      body['divisionOneLabel'] = divisionOneLabel;
    }
    if (divisionTwoLabel != null && divisionTwoLabel.isNotEmpty) {
      body['divisionTwoLabel'] = divisionTwoLabel;
    }
    if (divisionThreeLabel != null && divisionThreeLabel.isNotEmpty) {
      body['divisionThreeLabel'] = divisionThreeLabel;
    }

    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      } else {
        debugPrint(
          ' Failed with status ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint(' Exception: $e');
      return null;
    }
  }

  void _filterCountries() {
    if (!isDataLoaded) return;

    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCountries = List.from(countries);
      } else {
        filteredCountries = countries.where((country) {
          final name = country.country.toLowerCase();
          return name.contains(query);
        }).toList();
      }
      debugPrint("Searching in ${countries.length} items");
    });
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterCountries);
    getallCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        iconTheme: IconThemeData(color: _accentColor),
        elevation: 0,

        // title: Text('Countries', style: TextStyle(color: Colors.white)),
        title: Text(
          isMultiSelectMode ? '${selectedIds.length} selected' : 'Countries',
          style: TextStyle(color: _textPrimary),
        ),
        actions: isMultiSelectMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final confirmed = await deleteCountries(
                      selectedIds.toList(),
                    );
                    if (confirmed) {
                      setState(() {
                        countries.removeWhere(
                          (x) => selectedIds.contains(x.id),
                        );
                        getallCountries();
                        selectedIds.clear();
                        isMultiSelectMode = false;
                      });
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

          //list
          Expanded(
            child: isDataLoaded
                ? filteredCountries.isEmpty
                      ? Center(
                          child: Text(
                            'No countries found',
                            style: TextStyle(color: _textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCountries.length,
                          itemBuilder: (context, index) {
                            final c = filteredCountries[index];
                            final isSelected = selectedIds.contains(c.id);

                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  isMultiSelectMode = true;
                                  selectedIds.add(c.id);
                                });
                              },
                              onTap: () {
                                if (isMultiSelectMode) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedIds.remove(c.id);
                                      if (selectedIds.isEmpty)
                                        isMultiSelectMode = false;
                                    } else {
                                      selectedIds.add(c.id);
                                    }
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Division1View(
                                        // countryId: c.id,
                                        country: c,
                                        // divisionLabel: c.divisionOneLabel,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Card(
                                color: isMultiSelectMode && isSelected
                                    ? Colors.grey[700]
                                    : _cardColor,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // ─ Left: Country Info ─
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.country,
                                              style: TextStyle(
                                                color: _textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${c.divisionOneLabel} > ${c.divisionTwoLabel} > ${c.divisionThreeLabel}',
                                              style: TextStyle(
                                                color: _textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ─ Right: Status or Delete/Select ─
                                      if (!isMultiSelectMode) ...[
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.mode_edit_outlined,
                                                color: _accentColor,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => CountryDetailDialog(
                                                    country:
                                                        c, // CountryModel object
                                                    cardColor: _cardColor,
                                                    textPrimary: _textPrimary,
                                                    textSecondary:
                                                        _textSecondary,
                                                    accentColor: _accentColor,
                                                    onEdit: () {
                                                      Navigator.pop(
                                                        context,
                                                      ); // Close detail dialog
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => EditCountryDialog(
                                                          country: c,
                                                          cardColor: _cardColor,
                                                          textPrimary:
                                                              _textPrimary,
                                                          textSecondary:
                                                              _textSecondary,
                                                          accentColor:
                                                              _accentColor,
                                                          onUpdate: (updatedData) => updateCountry(
                                                            id: updatedData['id'],
                                                            country:
                                                                updatedData['country'],
                                                            divisionOneLabel:
                                                                updatedData['divisionOneLabel'],
                                                            divisionTwoLabel:
                                                                updatedData['divisionTwoLabel'],
                                                            divisionThreeLabel:
                                                                updatedData['divisionThreeLabel'],
                                                          ),
                                                          onUpdated: () {
                                                            getallCountries();
                                                          },
                                                          onCancel: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    onCancel: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                );
                                              },
                                            ),

                                            Transform.scale(
                                              scale: 0.7,
                                              child: Switch(
                                                value: c.status,
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
                                                            'Are you sure you want to ${val ? 'activate' : 'deactivate'} this country?',
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
                                                        await _updateCountryStatus(
                                                          c.id,
                                                          val,
                                                        );

                                                    if (success) {
                                                      setState(() {
                                                        c.status = val;
                                                      });
                                                      SnackbarHelper.showError(
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
                                                              'Are you sure you want to delete the country "${c.country}"?',
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
                                                      await deleteCountries([
                                                        c.id,
                                                      ]);
                                                  if (success) {
                                                    setState(() {
                                                      countries.removeWhere(
                                                        (x) => x.id == c.id,
                                                      );
                                                      filteredCountries
                                                          .removeWhere(
                                                            (x) => x.id == c.id,
                                                          );
                                                    });
                                                    SnackbarHelper.showError(
                                                      'Country Deleted Successfully',
                                                    );
                                                  } else {
                                                    SnackbarHelper.showError(
                                                      'Failed to delete country',
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ] else
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                selectedIds.add(c.id);
                                              } else {
                                                selectedIds.remove(c.id);
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
                : Center(child: Text("no Countries Added")),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        child: Icon(Icons.add, color: _bgColor),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddCountryDialog(
              onSubmit:
                  ({
                    required String country,
                    required String divisionOne,
                    required String divisionTwo,
                    required String divisionThree,
                  }) async {
                    await _addCountry(
                      country: country,
                      divisionOne: divisionOne,
                      divisionTwo: divisionTwo,
                      divisionThree: divisionThree,
                    );
                  },
            ),
          );
        },
      ),
    );
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
}

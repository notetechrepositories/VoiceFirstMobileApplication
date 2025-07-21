import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Models/country_model.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_add.dart';
import 'package:voicefirst/Views/AdminSide/CountryManagement/Country/country_detail_view.dart';

class CountryView extends StatefulWidget {
  const CountryView({super.key});

  @override
  State<CountryView> createState() => _CountryViewState();
}

class _CountryViewState extends State<CountryView> {
  bool isMultiSelectMode = false;
  Set<String> selectedIds = {};

  Future<bool> _deleteDivision(String countryId, String divisionLevel) async {
    final url = Uri.parse('http://192.168.0.202:8022/api/country/division');

    final body = {'id': countryId, 'divisionLevel': divisionLevel};

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await getallCountries(); // refresh list
        return true;
      } else {
        debugPrint('Failed to delete division: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting division: $e');
      return false;
    }
  }

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
  final Color _chipColor = Color(0xFF212121); // chip background
  final Color _accentColor = Color(0xFFFCC737); // gold accent
  final Color _textPrimary = Colors.white; // main text
  final Color _textSecondary = Colors.white60; // secondary text
  // ──────────────────────────────────────

  // List<Map<String, dynamic>> countries = [];
  // List<Map<String, dynamic>> filteredCountries = [];
  bool isDataLoaded = false;

  Future<void> getallCountries() async {
    final url = Uri.parse('http://192.168.0.202:8022/api/country/all');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json['data'];

        //without using model
        // final fetched = dataList.map((country){
        //   return{
        //     'id':country['id'],
        //     'country': country['country'],
        // 'divisionOneLabel': country['divisionOneLabel'],
        // 'divisionTwoLabel': country['divisionTwoLabel'],
        // 'divisionThreeLabel': country['divisionThreeLabel'],
        // 'status': country['status'] == true ? 'active' : 'inactive',

        //   };
        // }).toList();

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
    final url = Uri.parse('http://192.168.0.202:8022/api/country');
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
        await getallCountries(); // refresh list
      } else {
        debugPrint('Failed to add country: ${response.statusCode}');
        _showConflictDialog();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add country')));
      }
    } catch (e) {
      debugPrint('Error: $e');
      _showConflictDialog();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  Future<bool> deleteCountries(List<String> id) async {
    final url = Uri.parse('http://192.168.0.202:8022/api/country');

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
    final url = Uri.parse('http://192.168.0.202:8022/api/country');

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

  // void _filterCountries() {
  //   if (!isDataLoaded) return; //Don't filter until data is ready

  //   final query = _searchController.text.toLowerCase();
  //   setState(() {
  //     if (query.isEmpty) {
  //       filteredCountries = List.from(countries);
  //     } else {
  //       filteredCountries = countries.where((country) {
  //         final name = (country.country ?? '').toLowerCase();
  //         return name.contains(query);
  //       }).toList();
  //     }
  //     debugPrint("Searching in ${countries.length} items");
  //   });
  // }

  void _filterCountries() {
    if (!isDataLoaded) return;

    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCountries = List.from(countries);
      } else {
        filteredCountries = countries.where((country) {
          final name = country.country.toLowerCase(); // ✅ Fix here
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
    getallCountries(); // ✅ call it here to fetch data
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
          style: TextStyle(color: _textSecondary),
        ),
        actions: isMultiSelectMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  // onPressed: () async {
                  //   final confirmed = await deleteCountries(
                  //     selectedIds.toList(),
                  //   );
                  //   if (confirmed) {
                  //     setState(() {
                  //       countries.removeWhere(
                  //         (x) => selectedIds.contains(x['id']),
                  //       );
                  //       // _filterActivities();
                  //       getallCountries();
                  //       selectedIds.clear();
                  //       isMultiSelectMode = false;
                  //     });
                  //   }
                  // },
                  onPressed: () async {
                    final confirmed = await deleteCountries(
                      selectedIds.toList(),
                    );
                    if (confirmed) {
                      // await getallCountries(); // Reload full list
                      setState(() {
                        // countries.removeWhere(
                        //   (x) => selectedIds.contains(x['id']),
                        // );
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
                                      builder: (_) => CountryDetailPage(
                                        country: c,
                                        onDelete:
                                            _deleteDivision, // ✅ Add this line
                                        bgColor: _bgColor,
                                        cardColor: _cardColor,
                                        textPrimary: _textPrimary,
                                        textSecondary: _textSecondary,
                                        accentColor: _accentColor,
                                      ),
                                    ),
                                  );

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => CountryDetailPage(
                                  //       country: c,
                                  //       bgColor: _bgColor,
                                  //       cardColor: _cardColor,
                                  //       textPrimary: _textPrimary,
                                  //       textSecondary: _textSecondary,
                                  //     ),
                                  //   ),
                                  // );
                                }
                              },

                              // onTap: () {
                              //   if (isMultiSelectMode) {
                              //     setState(() {
                              //       if (isSelected) {
                              //         selectedIds.remove(c.id);
                              //         if (selectedIds.isEmpty) {
                              //           isMultiSelectMode = false;
                              //         }
                              //       } else {
                              //         selectedIds.add(c.id);
                              //       }
                              //     }

                              //     );
                              //   }
                              //   // else open view/edit if needed
                              // },
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
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Failed to delete country',
                                                        ),
                                                      ),
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
                : Center(child: CircularProgressIndicator()),
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

  Future updateCountryStatus(String id, bool val) async {}
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
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

  final Dio _dio = ApiClient().dio;

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
    try {
      // use leading slash so it joins with ApiClient.baseUrl
      final res = await _dio.get('/country/all');

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final List<dynamic> dataList = (res.data['data'] as List?) ?? [];

        final fetched = dataList
            .map(
              (e) => CountryModel.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList();

        setState(() {
          countries = fetched;
          // keep your existing filter behavior
          filteredCountries = countries
              .where((c) => c.country.toLowerCase().contains(query))
              .toList();
          isDataLoaded = true;
        });
      } else {
        final msg = (res.data is Map && res.data['message'] is String)
            ? res.data['message'] as String
            : 'Failed to fetch countries';
        debugPrint(msg);
        // Optional: SnackbarHelper.showError(msg);
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      debugPrint('Countries fetch failed: $msg');
      // Optional: SnackbarHelper.showError(msg);
    } catch (e) {
      debugPrint('Exception occurred: $e');
    }
  }

  Future<void> _addCountry({
    required String country,
    required String countryCode,
    required String countryIsoCode,
    required String divisionOne,
    required String divisionTwo,
    required String divisionThree,
  }) async {
    try {
      final response = await _dio.post(
        '/country',
        data: {
          "country": country.trim(),
          "countryCode": countryCode.trim(),
          "countryIsoCode": countryIsoCode.trim().toUpperCase(),
          "divisionOneLabel": divisionOne.trim(),
          "divisionTwoLabel": divisionTwo.trim(),
          "divisionThreeLabel": divisionThree.trim(),
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );

      // options:
      // Options(validateStatus: (status) => status != null && status < 500);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['isSuccess'] == true) {
          debugPrint('Country added successfully');
          final data = response.data['data'] as Map<String, dynamic>;
          final added = CountryModel.fromJson(data);

          setState(() {
            countries.removeWhere((c) => c.id == added.id);
            countries.insert(0, added);
            filteredCountries = countries
                .where((c) => c.country.toLowerCase().contains(query))
                .toList();
          });

          SnackbarHelper.showSuccess('Country added successfully');
          // await getallCountries(); // refresh list
        } else {
          final msg =
              (response.data is Map && response.data['message'] is String)
              ? response.data['message'] as String
              : 'failed to add country';
          SnackbarHelper.showError(msg);
        }
      } else {
        final msg = (response.data is Map && response.data['message'] is String)
            ? response.data['message'] as String
            : 'failed to add country';
        debugPrint('Failed to add country: ${response.statusCode}');
        _showConflictDialog();
        SnackbarHelper.showError(msg);
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response?.data['message'] as String
          : (e.message ?? 'Request failed');
      _showConflictDialog();
      SnackbarHelper.showError(msg);
    } catch (e) {
      debugPrint('Error: $e');
      _showConflictDialog();
      SnackbarHelper.showError('Something Went Wrong');
    }
  }

  Future<bool> deleteCountries(List<String> ids) async {
    final url = '/country';

    try {
      final response = await _dio.delete(url, data: ids);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // final json = jsonDecode(response.data);
        return response.data['isSuccess'] == true;
      } else {
        final msg = (response.data is Map && response.data['message'] is String)
            ? response.data['message'] as String
            : 'Delete failed';
        SnackbarHelper.showError(msg);
        debugPrint('delete failed with status:${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      SnackbarHelper.showError(msg);
      return false;
    } catch (e) {
      debugPrint('Error deleting country: $e');
      return false;
    }
  }

  //update status
  Future<bool> _updateCountryStatus(String id, bool status) async {
    // final url = ;

    try {
      final response = await _dio.patch(
        '/country',
        data: {'id': id, 'status': status},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        if (response.data['isSuccess'] == true) {
          debugPrint('Status updated to $status');
          return true;
        } else {
          final msg = (response.data['message'] is String)
              ? response.data['message'] as String
              : 'Failed to update status';
          SnackbarHelper.showError(msg);
          return false;
        }
      } else if (response.statusCode == 409) {
        _showConflictDialog(); // <-- Call custom dialog
        return false;
      } else {
        final msg = (response.data is Map && response.data['message'] is String)
            ? response.data['message'] as String
            : 'Failed to update status';
        SnackbarHelper.showError(msg);
        debugPrint('Failed to update status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      SnackbarHelper.showError(msg);
      return false;
    } catch (e) {
      SnackbarHelper.showError('Error updating status');
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> updateCountry({
    required String id,
    String? country,
    String? countryCode,
    String? countryIsoCode,
    String? divisionOneLabel,
    String? divisionTwoLabel,
    String? divisionThreeLabel,
  }) async {
    final body = <String, dynamic>{'id': id};

    if (country != null && country.isNotEmpty) {
      body['country'] = country;
    }
    if (countryCode != null && countryCode.isEmpty) {
      body['countryCode'] = countryCode;
    }
    if (countryIsoCode != null && countryIsoCode.isEmpty) {
      body['countryIsoCode'] = countryIsoCode;
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

    final url = '/country';

    try {
      final response = await _dio.put(url, data: body);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // final json = jsonDecode(response.body);
        if (response.data['isSuccess'] == true) {
          final data = response.data['data'];
          return (data is Map<String, dynamic>) ? data : null;
        } else {
          final msg = (response.data['message'] is String)
              ? response.data['message'] as String
              : 'Update failed';
          SnackbarHelper.showError(msg);
          return null;
        }
      } else {
        final msg = (response.data is Map && response.data['message'] is String)
            ? response.data['message'] as String
            : 'Update failed';
        SnackbarHelper.showError(msg);
        debugPrint(
          ' Failed with status ${response.statusCode}: ${response.data}',
        );
        return null;
      }
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : (e.message ?? 'Request failed');
      SnackbarHelper.showError(msg);
      return null;
    } catch (e) {
      SnackbarHelper.showError('Unexpected error');
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
                    if (selectedIds.isEmpty) return;

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text(
                          'Are you sure want to delete the selected Countries?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final ok = await deleteCountries(selectedIds.toList());
                    if (ok) {
                      setState(() {
                        countries.removeWhere(
                          (x) => selectedIds.contains(x.id),
                        );
                        filteredCountries.removeWhere(
                          (x) => selectedIds.contains(x.id),
                        );
                        selectedIds.clear();
                        isMultiSelectMode = false;
                      });
                      SnackbarHelper.showSuccess('Selected countries deleted');
                    } else {
                      SnackbarHelper.showError(
                        'Failed to delete selected countries',
                      );
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
                            // build divisions string (simple string ops)
                            final d1 = (c.divisionOneLabel ?? '').trim();
                            final d2 = (c.divisionTwoLabel ?? '').trim();
                            final d3 = (c.divisionThreeLabel ?? '').trim();

                            String divisions = '';
                            if (d1.isNotEmpty) divisions = d1;
                            if (d2.isNotEmpty) {
                              divisions +=
                                  (divisions.isEmpty ? '' : ' > ') + d2;
                            }
                            if (d3.isNotEmpty) {
                              divisions +=
                                  (divisions.isEmpty ? '' : ' > ') + d3;
                            }
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
                                      if (selectedIds.isEmpty) {
                                        isMultiSelectMode = false;
                                      }
                                    } else {
                                      selectedIds.add(c.id);
                                    }
                                  });
                                } else if ((c.divisionOneLabel ?? '')
                                    .trim()
                                    .isNotEmpty) {
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
                                } else {
                                  HapticFeedback.lightImpact();
                                  SnackbarHelper.showInfo(
                                    'No further divisions configured for ${c.country}.',
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

                                            divisions.isNotEmpty
                                                ? Text(
                                                    divisions,
                                                    style: TextStyle(
                                                      color: _textSecondary,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
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
                                                          onUpdate: (updatedData) async {
                                                            final data = await updateCountry(
                                                              id: updatedData['id'],
                                                              country:
                                                                  updatedData['country'],
                                                              countryCode:
                                                                  updatedData['countryCode'],
                                                              countryIsoCode:
                                                                  updatedData['countryIsoCode'],
                                                              divisionOneLabel:
                                                                  updatedData['divisionOneLabel'],
                                                              divisionTwoLabel:
                                                                  updatedData['divisionTwoLabel'],
                                                              divisionThreeLabel:
                                                                  updatedData['divisionThreeLabel'],
                                                            );
                                                            if (data != null) {
                                                              final updated =
                                                                  CountryModel.fromJson(
                                                                    data,
                                                                  );
                                                              setState(() {
                                                                final idx = countries
                                                                    .indexWhere(
                                                                      (e) =>
                                                                          e.id ==
                                                                          updated
                                                                              .id,
                                                                    );
                                                                if (idx != -1) {
                                                                  countries[idx] =
                                                                      updated;
                                                                } else {
                                                                  countries
                                                                      .insert(
                                                                        0,
                                                                        updated,
                                                                      );
                                                                }
                                                                _filterCountries();
                                                              });
                                                            }
                                                            return data;
                                                          },
                                                          onUpdated: () {},
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
                                                value: c.status!,
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
                                                    SnackbarHelper.showSuccess(
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
                    required String countryCode,
                    required String countryIsoCode,
                    required String divisionOne,
                    required String divisionTwo,
                    required String divisionThree,
                  }) async {
                    await _addCountry(
                      country: country,
                      countryCode: countryCode,
                      countryIsoCode: countryIsoCode,
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/country_model.dart';

class Testcountry extends StatefulWidget {
  const Testcountry({super.key});

  @override
  _TestcountryState createState() => _TestcountryState();
}

class _TestcountryState extends State<Testcountry> {
  final String _errorMessage = '';

  List<Map<String, dynamic>> divisions = [];
  List<Map<String, dynamic>> filteredDivisions = [];

  List<CountryModel> countries = [];
  List<CountryModel> filteredCountries = [];
  bool isDataLoaded = false;
  String query = '';

  // Fetch the countries from API
  // getallcountries
  Future<void> getallCountries() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/country');

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

  @override
  void initState() {
    super.initState();
    getallCountries(); // Fetch countries when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Countries List"),
        backgroundColor: Colors.blue,
      ),
      body: countries.isEmpty && _errorMessage.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            ) // Show loading indicator while fetching data
          : countries.isEmpty
          ? Center(
              child: Text(_errorMessage),
            ) // Show error message if no countries
          : ListView.builder(
              itemCount: countries.length,

              itemBuilder: (context, index) {
                final c = filteredCountries[index];
                return ListTile(title: Text(c.country));
              },
            ),
    );
  }
}

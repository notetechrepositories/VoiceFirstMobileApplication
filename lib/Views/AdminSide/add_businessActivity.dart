import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Widgets/dynamic_drawer.dart';

class AddBusinessactivity extends StatefulWidget {
  const AddBusinessactivity({super.key});

  @override
  State<AddBusinessactivity> createState() => _AddBusinessactivityState();
}

class _AddBusinessactivityState extends State<AddBusinessactivity> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredActivities = [];
  List<MenuItem> menuItems = [];

  final List<Map<String, dynamic>> activities = [
    {
      "id": "010110101",
      "business_activity_name": "hgjhkgkg",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110111",
      "business_activity_name": "activity4",
      "company": "y",
      "branch": "y",
      "section": "y",
      "sub_section": "y",
    },
    {
      "id": "010110011",
      "business_activity_name": "new name3",
      "company": "y",
      "branch": "y",
      "section": "n",
      "sub_section": "n",
    },
  ];

  @override
  void initState() {
    super.initState();
    loadMenu();
    filteredActivities = List.from(activities);
    _searchController.addListener(_filterActivities);
    // loadActivities();
  }

  Future<void> loadMenu() async {
    final url = Uri.parse('http://10.0.2.2:5132/api/menu/get-menu');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final items = (jsonData['data']['Items'] as List)
            .map((e) => MenuItem.fromJson(e))
            .toList();

        setState(() {
          menuItems = buildMenuTree(items);
        });
      } else {
        print('Menu fetch failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Menu load error: $e');
    }
  }

  List<MenuItem> buildMenuTree(List<MenuItem> flatList) {
    flatList.sort((a, b) => a.position.compareTo(b.position));
    Map<String, MenuItem> positionMap = {
      for (var item in flatList) item.position: item,
    };

    List<MenuItem> roots = [];

    for (var item in flatList) {
      if (item.position.length == 1) {
        roots.add(item);
      } else {
        final parentPos = item.position.substring(0, item.position.length - 1);
        if (positionMap.containsKey(parentPos)) {
          positionMap[parentPos]!.children = [
            ...positionMap[parentPos]!.children,
            item,
          ];
        }
      }
    }

    return roots;
  }

  void _filterActivities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredActivities = activities.where((activity) {
        final name = activity['business_activity_name']!.toLowerCase();
        // final type =
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: CustomDrawer(items: menuItems),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'System Activities',
                  style: TextStyle(color: Color(0xFFAAAAAA)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: filteredActivities.length,
          //     itemBuilder: (context, index) {
          //       final activity = filteredActivities[index];
          //       return Card(
          //         color: Colors.grey[900],
          //         margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadiusGeometry.circular(12),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

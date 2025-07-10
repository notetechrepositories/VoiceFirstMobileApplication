import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. import your model & drawer
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Views/AdminSide/add_business_activity.dart';
import 'package:voicefirst/Widgets/dynamic_drawer.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
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

  // List<MenuItem> buildMenuTree(List<MenuItem> flatList) {
  //   flatList.sort((a, b) => a.position.compareTo(b.position));
  //   final map = { for (var i in flatList) i.position : i };
  //   List<MenuItem> roots = [];
  //   for (var item in flatList) {
  //     if (item.position.length == 1) {
  //       roots.add(item);
  //     } else {
  //       final parentPos = item.position.substring(0, item.position.length - 1);
  //       if (map.containsKey(parentPos)) {
  //         map[parentPos]!.children.add(item);
  //       }
  //     }
  //   }
  //   return roots;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. attach the drawer here
      drawer: CustomDrawer(items: menuItems),

      appBar: AppBar(title: const Text('Admin Home')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddBusinessactivity()),
              );
            },
            child: Text('add activity'),
          ),
        ],
      ),
    );
  }
}

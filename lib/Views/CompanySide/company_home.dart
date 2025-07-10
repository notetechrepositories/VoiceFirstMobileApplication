import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Views/CompanySide/add_business.dart';
import 'package:voicefirst/Widgets/dynamic_drawer.dart';

class CompanyHome extends StatefulWidget {
  const CompanyHome({super.key});

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    final url = Uri.parse('http://192.168.0.180:8064/api/menu/get-menu');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(items: menuItems),
      appBar: AppBar(title: Text('Company Home')),
    );
  }
}

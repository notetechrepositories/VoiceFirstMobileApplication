import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/menu_service.dart';
import 'package:voicefirst/Models/menu_item_model.dart';
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
    try {
      final items = await fetchMenu(); // uses Dio + builds tree for you
      setState(() => menuItems = items);
    } catch (e) {
      debugPrint('Menu load error: $e');
      setState(() => menuItems = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(items: menuItems),
      appBar: AppBar(title: Text('Company Home')),
      body: Column(),
    );
  }
}

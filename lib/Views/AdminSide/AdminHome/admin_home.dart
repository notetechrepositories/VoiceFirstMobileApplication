import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Services/menu_service.dart';

// 1. import your model & drawer
import 'package:voicefirst/Models/menu_item_model.dart';
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
    try {
      final items = await fetchMenu(); // Dio + parsed + tree built
      if (!mounted) return;
      setState(() => menuItems = items);
    } catch (e) {
      debugPrint('Menu load error: $e');
      if (!mounted) return;
      setState(() => menuItems = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. attach the drawer here
      drawer: CustomDrawer(items: menuItems),

      appBar: AppBar(title: const Text('Admin Home')),
      // body: Column( ),
    );
  }
}

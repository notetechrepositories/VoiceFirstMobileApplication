import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Core/Constants/api_endpoins.dart';
import 'package:voicefirst/Models/menu_item_model.dart';
import 'package:voicefirst/Views/CompanySide/BusinessActivity/business_activity_comp.dart';
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
    final url = Uri.parse('${ApiEndpoints.baseUrl}/menus/app');
    try {
      final res = await http.get(url);
      print(res);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);

        // final items = (jsonData['data']['Items'] as List)
        //     .map((e) => MenuItem.fromJson(e))
        //     .toList();

        final items = (jsonData['data'] as List)
            .map((e) => MenuItem.fromJson(e))
            .toList();

        setState(() {
          menuItems = buildMenuTree(items);
          print(menuItems);
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
      body: Column(
        
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:voicefirst/Views/CompanySide/add_activity.dart';
// // import 'add_activity_page.dart'; // Import the AddActivityPage

// class AddBusiness extends StatefulWidget {
//   const AddBusiness({super.key});

//   @override
//   State<AddBusiness> createState() => _AddBusinessState();
// }

// class _AddBusinessState extends State<AddBusiness> {
//   List<Map<String, dynamic>> activities = [];

//   void _addNewActivities(List<Map<String, dynamic>> newActivities) {
//     setState(() {
//       activities.addAll(newActivities); // Add all new activities to the list
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Business Activities")),
//       body: Column(
//         children: [
//           Expanded(
//             child: activities.isEmpty
//                 ? Center(child: Text('No activities added.'))
//                 : ListView.builder(
//                     itemCount: activities.length,
//                     itemBuilder: (context, index) {
//                       final activity = activities[index];
//                       return ListTile(
//                         title: Text(activity['business_activity_name']),
//                         subtitle: Text('Company: ${activity['company']}'),
//                       );
//                     },
//                   ),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               // Navigate to AddActivityPage
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       AddActivityPage(onActivitiesAdded: _addNewActivities),
//                 ),
//               );
//             },
//             child: Icon(Icons.add),
//           ),
//         ],
//       ),
//     );
//   }
// }
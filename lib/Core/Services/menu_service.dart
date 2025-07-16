import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Models/menu_item_model.dart';

Future<List<MenuItem>> fetchMenu() async {
  final url = Uri.parse('http://192.168.0.180:8064/api/menu/get-menu');

  try {
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      final items = (jsonData['data']['Items'] as List)
          .map((e) => MenuItem.fromJson(e))
          .toList();

      return buildMenuTree(items);
    } else {
      print('Menu fetch failed: ${res.statusCode}');
      return [];
    }
  } catch (e) {
    print('Menu load error: $e');
    return [];
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

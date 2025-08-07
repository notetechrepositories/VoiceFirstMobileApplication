import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Models/menu_item_model.dart';
import '../Constants/api_endpoins.dart';

Future<List<MenuItem>> fetchMenu() async {
  final url = Uri.parse('${ApiEndpoints.baseUrl}/menus/app');

  try {
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      final items = (jsonData['data'] as List)
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
  // Sort by position for predictable order
  flatList.sort((a, b) => a.position.compareTo(b.position));

  // Map each item's position for fast lookup
  final Map<String, MenuItem> positionMap = {
    for (var item in flatList) item.position: item,
  };

  // Set to track positions that should be ignored because parent has a route
  final Set<String> disabledPrefixes = {};

  // Step 1: Identify parent positions with non-empty routes
  for (var item in flatList) {
    if (item.route != null && item.route!.isNotEmpty) {
      disabledPrefixes.add(item.position);
    }
  }

  // Step 2: Build the tree
  List<MenuItem> roots = [];

  for (var item in flatList) {
    // Skip if this item's position starts with a disabled prefix (e.g., "F", "FA", "FAB")
    if (disabledPrefixes.any(
      (prefix) => item.position != prefix && item.position.startsWith(prefix),
    )) {
      continue;
    }

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

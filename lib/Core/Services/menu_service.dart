// lib/Core/Services/menu_service.dart
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
      final raw = (jsonData['data'] as List? ?? []);

      // Parse with safe defaults
      final allItems = raw
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // IMPORTANT: Only exclude items explicitly marked as deleted.
      // Do NOT exclude inactive/null-active items—let backend decide visibility.
      final items = allItems
          .where((m) => !m.deleted && m.position.isNotEmpty)
          .toList();
      print('Parsed items: ${allItems.length}, kept: ${items.length}');
      for (final i in items) {
        print('> ${i.position} | ${i.name} | route=${i.route}');
      }

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

  // Collect positions that have a non-empty route.
  // Any descendant of those positions is hidden (parent remains).
  final Set<String> disabledPrefixes = {
    for (var item in flatList)
      if ((item.route ?? '').isNotEmpty) item.position,
  };

  final List<MenuItem> roots = [];

  for (var item in flatList) {
    // Hide descendants under a routed parent; keep the parent itself.
    final underDisabledParent = disabledPrefixes.any(
      (prefix) => item.position != prefix && item.position.startsWith(prefix),
    );
    if (underDisabledParent) continue;

    if (item.position.length == 1) {
      roots.add(item);
    } else {
      final parentPos = item.position.substring(0, item.position.length - 1);
      final parent = positionMap[parentPos];
      if (parent != null) {
        parent.children = [...parent.children, item];
      } else {
        // If parent is missing (bad data), treat as root so it still shows
        roots.add(item);
      }
    }
  }

  return roots;
}

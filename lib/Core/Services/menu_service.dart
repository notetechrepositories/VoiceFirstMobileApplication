// lib/Core/Services/menu_service.dart
import 'package:dio/dio.dart';
import 'package:voicefirst/Core/Services/api_client.dart';
import '../../Models/menu_item_model.dart';

Future<List<MenuItem>> fetchMenu() async {
  final Dio _dio = ApiClient().dio;

  final url = '/menus/app';

  try {
    final res = await _dio.get(url);
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final root = res.data as Map<String, dynamic>;
      final data = root['data'];
      final raw =
          (data is Map<String, dynamic> ? data['menus'] : null) as List? ?? [];

      final allItems = raw
          .whereType<Map>()
          .map((e) => MenuItem.fromJson((e).cast<String, dynamic>()))
          .toList();

      // IMPORTANT: Only exclude items explicitly marked as deleted.
      // Do NOT exclude inactive/null-active items—let backend decide visibility.

      // Keep only items explicitly not deleted and with a position
      // (if  model’s `deleted` defaults to false, this works even if field is missing)
      final items = allItems
          .where((m) => !m.deleted && m.position.isNotEmpty)
          .toList();
      // Debug (optional)
      print('Parsed items: ${allItems.length}, kept: ${items.length}');
      for (final i in items) {
        print('> ${i.position} | ${i.name} | route=${i.route}');
      }

      return buildMenuTree(items);
    } else {
      print('Menu fetch failed: ${res.statusCode}');
      return [];
    }
  } on DioException catch (e) {
    print(
      'Menu load error: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
    );
    return [];
  } catch (e) {
    print('Menu load error: $e');
    return [];
  }
}

// List<MenuItem> buildMenuTree(List<MenuItem> flatList) {
//   // Sort by position for predictable order
//   flatList.sort((a, b) => a.position.compareTo(b.position));

//   //reset children to avoid repeat calls
//   for(final item in flatList){
//     item.children.clear();
//   }

//   // Map each item's position for fast lookup
//   final Map<String, MenuItem> positionMap = {
//     for (var item in flatList) item.position: item,
//   };

//   // Collect positions that have a non-empty route.
//   // Any descendant of those positions is hidden (parent remains).
//   final Set<String> disabledPrefixes = {
//     for (var item in flatList)
//       if ((item.route ?? '').isNotEmpty) item.position,
//   };

//   final List<MenuItem> roots = [];

//   for (var item in flatList) {
//     // Hide descendants under a routed parent; keep the parent itself.
//     final underDisabledParent = disabledPrefixes.any(
//       (prefix) => item.position != prefix && item.position.startsWith(prefix),
//     );
//     if (underDisabledParent) continue;

//     if (item.position.length == 1) {
//       roots.add(item);
//     } else {
//       final parentPos = item.position.substring(0, item.position.length - 1);
//       final parent = positionMap[parentPos];
//       if (parent != null) {
//         parent.children = [...parent.children, item];
//       } else {
//         // If parent is missing (bad data), treat as root so it still shows
//         roots.add(item);
//       }
//     }
//   }

//   return roots;
// }
List<MenuItem> buildMenuTree(List<MenuItem> flatList) {
  flatList.sort((a, b) => a.position.compareTo(b.position));

  // Reset children so repeated calls don’t accumulate duplicates
  for (final item in flatList) {
    // If children is non-final:
    // item.children = [];
    // If children is final:
    item.children.clear();
  }

  final positionMap = {for (final item in flatList) item.position: item};

  final disabledPrefixes = {
    for (final item in flatList)
      if ((item.route ?? '').isNotEmpty) item.position,
  };

  final roots = <MenuItem>[];

  for (final item in flatList) {
    final underDisabledParent = disabledPrefixes.any(
      (p) => item.position != p && item.position.startsWith(p),
    );
    if (underDisabledParent) continue;

    if (item.position.length == 1) {
      roots.add(item);
    } else {
      final parentPos = item.position.substring(0, item.position.length - 1);
      final parent = positionMap[parentPos];
      if (parent != null) {
        parent.children.add(item); // use add() instead of [..., item]
      } else {
        roots.add(item);
      }
    }
  }

  return roots;
}

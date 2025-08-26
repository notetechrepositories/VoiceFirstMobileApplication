// // models/menu_item_model.dart
// class MenuItem {
//   final String id;
//   final String name;
//   final String? icon;
//   final String? route; // nullable
//   final String position; // can be "" if missing
//   final bool active; // default false if null
//   final bool deleted; // `delete` in API
//   List<MenuItem> children;

//   MenuItem({
//     required this.id,
//     required this.name,
//     required this.position,
//     this.icon,
//     this.route,
//     this.active = false,
//     this.deleted = false,
//     this.children = const [],
//   });

//   bool get isLeaf => (route != null && route!.trim().isNotEmpty);

//   factory MenuItem.fromJson(Map<String, dynamic> json) {
//     return MenuItem(
//       id: (json['id'] ?? '').toString(),
//       name: (json['name'] ?? '').toString(),
//       icon: (json['icon'] as String?)?.trim(),
//       route: (json['route'] as String?)?.trim(), // may be ""
//       position: (json['position'] ?? '').toString(),
//       active: (json['active'] as bool?) ?? false,
//       deleted: (json['delete'] as bool?) ?? false,
//       children: const [],
//     );
//   }
// }

// models/menu_item_model.dart
class MenuItem {
  final String id;
  final String name;
  final String? icon;
  final String? route; // nullable
  final String position; // can be "" if missing
  final bool active; // default false if null
  final bool deleted; // maps 'delete' from API
  final List<MenuItem> children; // final + mutable list

  MenuItem({
    required this.id,
    required this.name,
    required this.position,
    this.icon,
    this.route,
    this.active = false,
    this.deleted = false,
    List<MenuItem>? children, // <-- accept nullable
  }) : children = List<MenuItem>.from(
         children ?? const [],
       ); // <-- growable copy

  bool get isLeaf => (route != null && route!.trim().isNotEmpty);

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] as String?)?.trim(),
      route: (json['route'] as String?)?.trim(), // may be ""
      position: (json['position'] ?? '').toString(),
      active: (json['active'] as bool?) ?? false,
      deleted: (json['delete'] as bool?) ?? false,
      children: const [], // fine: constructor makes a growable copy
    );
  }
}

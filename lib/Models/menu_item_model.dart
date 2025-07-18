class MenuItem {
  final String id;
  final String name;
  final String icon;
  final String route;
  final String position;
  List<MenuItem> children;

  MenuItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    required this.position,
    this.children = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      icon: json['icon'],
      route: json['route'] ?? '',
    );
  }

  // factory MenuItem.fromJson(Map<String, dynamic> json) {
  //   return MenuItem(
  //     id: json['id'] ?? '',
  //     name: json['name'] ?? '',
  //     icon: json['icon'] ?? '',
  //     route: json['route'] ?? '',
  //     position: json['position'] ?? '',
  //   );
  // }
}

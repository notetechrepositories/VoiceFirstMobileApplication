class MenuItem {
  final String id;
  final String name;
  final String? icon;
  final String? route;
  final String position;
  final bool active;
  final bool delete;
  List<MenuItem> children;

  MenuItem({
    required this.id,
    required this.name,
    this.icon,
    this.route,
    required this.position,
    required this.active,
    required this.delete,
    this.children = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      route: json['route'] ?? '',
      position: json['position'],
      active: json['active'],
      delete: json['delete'],
    );
  }
}

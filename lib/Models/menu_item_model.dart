class MenuItem {
  final int id;
  final String name;
  final String position;
  final String icon;
  final String? route;
  List<MenuItem> children;

  MenuItem({
    required this.id,
    required this.name,
    required this.position,
    required this.icon,
    this.route,
    this.children = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id_t7_2_menu'],
      name: json['t7_2_menu_name'],
      position: json['t7_2_position'],
      icon: json['t7_2_icon'],
      route: json['t7_2_route'],
    );
  }
}

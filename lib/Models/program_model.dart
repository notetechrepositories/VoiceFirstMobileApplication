class ProgramModel {
  final String id;
  final String label;
  final bool route;
  final bool create;
  final bool update;
  final bool view;
  final bool delete;
  final bool download;
  final bool email;

  ProgramModel({
    required this.id,
    required this.label,
    required this.route,
    required this.create,
    required this.update,
    required this.view,
    required this.delete,
    required this.download,
    required this.email,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      route: json['route'] ?? false,
      create: json['create'] ?? false,
      update: json['update'] ?? false,
      view: json['view'] ?? false,
      delete: json['delete'] ?? false,
      download: json['download'] ?? false,
      email: json['email'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'route': route,
      'create': create,
      'update': update,
      'view': view,
      'delete': delete,
      'download': download,
      'email': email,
    };
  }
}

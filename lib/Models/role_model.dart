import 'permission_model.dart';

class RoleModel {
  final String? id;
  final String name;
  final bool allLocationAccess;
  final bool allIssueAccess;
  final bool status;
  final List<ProgramPermissionModel> permissions;

  RoleModel({
    this.id,
    required this.name,
    required this.allLocationAccess,
    required this.allIssueAccess,
    required this.status,
    required this.permissions,
  });

  factory RoleModel.fromJson(
    Map<String, dynamic> json,
    Map<String, String> programLabelsMap,
  ) {
    return RoleModel(
      id: json['id'],
      name: json['roleName'] ?? '',
      allLocationAccess: json['allLocationAccess'] ?? false,
      allIssueAccess: json['allIssuesAccess'] ?? false,
      status: json['status'] ?? false,
      permissions: (json['rolePrograms'] as List)
          .map(
            (e) => ProgramPermissionModel.fromJson(
              e,
              programLabelsMap[e['programId']] ?? 'Unknown',
              // Add these extra permission flags for controlling enable/disable
              canCreate: e['create'] ?? false,
              canUpdate: e['update'] ?? false,
              canView: e['view'] ?? false,
              canDelete: e['delete'] ?? false,
              canDownload: e['download'] ?? false,
              canEmail: e['email'] ?? false,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson({bool includeIds = false}) {
    return {
      if (includeIds && id != null) 'id': id,
      'roleName': name,
      'allLocationAccess': allLocationAccess,
      'allIssuesAccess': allIssueAccess,
      'status': status,
      'rolePrograms': permissions
          .map((e) => e.toJson(includeId: includeIds))
          .toList(),
    };
  }
}

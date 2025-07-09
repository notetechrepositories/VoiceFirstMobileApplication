// models/permission_model.dart
class PermissionModel {
  final String module;
  bool create,
      read,
      update,
      delete,
      updateFromExcel,
      downloadExcel,
      downloadPdf;

  PermissionModel({
    required this.module,
    this.create = false,
    this.read = false,
    this.update = false,
    this.delete = false,
    this.updateFromExcel = false,
    this.downloadExcel = false,
    this.downloadPdf = false,
  });
}

// models/role_model.dart
class RoleModel {
  String name;
  bool allLocationAccess;
  bool allIssueAccess;
  List<PermissionModel> permissions;

  RoleModel({
    required this.name,
    this.allLocationAccess = false,
    this.allIssueAccess = false,
    required this.permissions,
  });
}

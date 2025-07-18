class ProgramPermissionModel {
  final String programId;
  final String? label;
  bool create;
  bool update;
  bool view;
  bool delete;
  bool download;
  bool email;

  // New fields to determine if checkbox is enabled
  bool canCreate;
  bool canUpdate;
  bool canView;
  bool canDelete;
  bool canDownload;
  bool canEmail;

  ProgramPermissionModel({
    required this.programId,
    this.label,
    this.create = false,
    this.update = false,
    this.view = false,
    this.delete = false,
    this.download = false,
    this.email = false,
    this.canCreate = true,
    this.canUpdate = true,
    this.canView = true,
    this.canDelete = true,
    this.canDownload = true,
    this.canEmail = true,
  });

  factory ProgramPermissionModel.fromJson(
    Map<String, dynamic> json,
    String label, {
    bool canCreate = true,
    bool canUpdate = true,
    bool canView = true,
    bool canDelete = true,
    bool canDownload = true,
    bool canEmail = true,
  }) {
    return ProgramPermissionModel(
      programId: json['programId'],
      label: label,
      create: json['create'] ?? false,
      update: json['update'] ?? false,
      view: json['view'] ?? false,
      delete: json['delete'] ?? false,
      download: json['download'] ?? false,
      email: json['email'] ?? false,
      canCreate: canCreate,
      canUpdate: canUpdate,
      canView: canView,
      canDelete: canDelete,
      canDownload: canDownload,
      canEmail: canEmail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'programId': programId,
      'create': create,
      'update': update,
      'view': view,
      'delete': delete,
      'download': download,
      'email': email,
    };
  }
}

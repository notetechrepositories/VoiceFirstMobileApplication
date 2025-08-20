// lib/Core/Services/role_service.dart
import 'package:dio/dio.dart';
import '../Services/api_client.dart';
import '../../Models/role_model.dart';
import '../../Models/permission_model.dart';

// GET /roles  (company-scoped)
Future<List<RoleModel>> fetchRoles() async {
  final dio = ApiClient().dio;

  final res = await dio.get(
    '/roles',
    options: Options(extra: {'auth': 'company'}),
  );

  if (res.statusCode == null || res.statusCode! ~/ 100 != 2) {
    throw Exception('Failed to fetch roles');
  }

  final List data = (res.data['data'] as List?) ?? const [];
  return data.map<RoleModel>((e) {
    final List<dynamic> rp = e['rolePrograms'] as List<dynamic>? ?? const [];
    final perms = rp.map((p) {
      return ProgramPermissionModel(
        id: p['id'] as String?,
        programId: (p['programId'] as String?) ?? '',
        label: p['label'] as String?,
        create: p['create'] == true,
        update: p['update'] == true,
        view: p['view'] == true,
        delete: p['delete'] == true,
        download: p['download'] == true,
        email: p['email'] == true,
      );
    }).toList();

    return RoleModel(
      id: e['id'] as String?,
      name: (e['roleName'] as String?) ?? '',
      allLocationAccess: e['allLocationAccess'] == true,
      allIssueAccess: e['allIssuesAccess'] == true,
      status: e['status'] != false,
      permissions: perms,
    );
  }).toList();
}

/// Delete roles by IDs with a JSON array body.
/// Contract: DELETE /roles
/// Body: ["id1","id2", ...]
Future<bool> deleteRoles(List<String> ids) async {
  final dio = ApiClient().dio;

  final body = ids.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (body.isEmpty) return false;

  final res = await dio.delete(
    '/roles',
    data: body, // JSON array
    options: Options(
      extra: {'auth': 'company'},
      // Don't throw on 404; we'll return false instead
      validateStatus: (code) => true,
    ),
  );

  // Treat any 2xx (incl. 204) as success
  return res.statusCode != null && res.statusCode! ~/ 100 == 2;
}

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
    options: Options(extra: {'auth': 'company'}), // important
  );

  if (res.statusCode == null || res.statusCode! ~/ 100 != 2) {
    throw Exception('Failed to fetch roles');
  }

  final List data = (res.data['data'] as List?) ?? const [];
  return data.map<RoleModel>((e) {
    // Map API -> app model
    final List<dynamic> rp = e['rolePrograms'] as List<dynamic>? ?? const [];
    final perms = rp.map((p) {
      return ProgramPermissionModel(
        id: p['id'] as String?,
        programId: (p['programId'] as String?) ?? '',
        // label often not present in rolePrograms; can be enriched later
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
      allIssueAccess: e['allIssuesAccess'] == true, // plural in API
      status: e['status'] != false,
      permissions: perms,
    );
  }).toList();
}

// DELETE /roles/{id} (loop simple version)
Future<bool> deleteRoles(List<String> ids) async {
  final dio = ApiClient().dio;

  for (final raw in ids) {
    final id = raw.trim();
    if (id.isEmpty) continue;

    final res = await dio.delete(
      '/roles/$id',
      options: Options(extra: {'auth': 'company'}),
    );

    if (res.statusCode == null || res.statusCode! ~/ 100 != 2) {
      return false;
    }
  }
  return true;
}

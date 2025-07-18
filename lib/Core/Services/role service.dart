import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Models/role_model.dart';

Future<List<RoleModel>> fetchRoles() async {
  final url = Uri.parse('http://192.168.0.111:8022/api/roles/all');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['isSuccess'] == true && body['data'] != null) {
        final List rolesJson = body['data'];
        return rolesJson.map((json) => RoleModel.fromJson(json, {})).toList();
      }
    } else {
      print('Failed to load roles: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching roles: $e');
  }
  return [];
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Models/role_model.dart';
import '../Constants/api_endpoins.dart';

Future<List<RoleModel>> fetchRoles() async {
  final url = Uri.parse('${ApiEndpoints.baseUrl}/roles/all');

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

Future<bool> deleteRoles(List<String> roleIds) async {
  final url = Uri.parse("${ApiEndpoints.baseUrl}/roles");

  try {
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(roleIds),
    );

    if (response.statusCode == 200) {
      print("Role(s) deleted successfully");
      return true;
    } else {
      print("Failed to delete roles: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Error deleting roles: $e");
    return false;
  }
}

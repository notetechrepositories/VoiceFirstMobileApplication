// views/role_list_screen.dart
import 'package:flutter/material.dart';
import '../../Models/permission_model.dart';
import 'add_role.dart';

class RoleListScreen extends StatefulWidget {
  @override
  _RoleListScreenState createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  List<RoleModel> roles = [
    RoleModel(
      name: 'Admin',
      allLocationAccess: true,
      allIssueAccess: true,
      permissions: [],
    ),
    RoleModel(
      name: 'User',
      allLocationAccess: false,
      allIssueAccess: false,
      permissions: [],
    ),
    RoleModel(
      name: 'Manager',
      allLocationAccess: true,
      allIssueAccess: true,
      permissions: [],
    ),
    RoleModel(
      name: 'Supervisor',
      allLocationAccess: true,
      allIssueAccess: true,
      permissions: [],
    ),
    RoleModel(
      name: 'Employee',
      allLocationAccess: false,
      allIssueAccess: false,
      permissions: [],
    ),
  ];

  void _addOrEditRole({RoleModel? existing}) async {
    final newRole = await showDialog<RoleModel>(
      context: context,
      builder: (_) => AddRoleDialog(role: existing),
    );
    if (newRole != null) {
      setState(() {
        if (existing != null) {
          final index = roles.indexOf(existing);
          roles[index] = newRole;
        } else {
          roles.add(newRole);
        }
      });
    }
  }

  void _deleteRole(RoleModel role) {
    setState(() {
      roles.remove(role);
    });
  }

  Widget _icon(bool val) => Icon(
    val ? Icons.check : Icons.close,
    color: val ? Colors.green : const Color.fromARGB(255, 246, 65, 52),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Manage System Roles"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  roles = roles
                      .where(
                        (role) => role.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
                      )
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: roles.length,
              itemBuilder: (_, index) {
                final role = roles[index];
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      role.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            "All Location Access: ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          _icon(role.allLocationAccess),
                          SizedBox(width: 20),
                          Text(
                            "All Issue Access: ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          _icon(role.allIssueAccess),
                        ],
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Color(0xFFFCC737)),
                          onPressed: () => _addOrEditRole(existing: role),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteRole(role),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEditRole,
        backgroundColor: Color(0xFFFCC737),
        foregroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
    );
  }
}

// lib/Views/Roles/role_list_screen.dart
import 'package:flutter/material.dart';
import 'package:voicefirst/Views/AdminSide/Roles/add_role.dart';
import '../../../Core/Services/role service.dart';
import '../../../Models/role_model.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  List<RoleModel> roles = [];
  String searchQuery = "";
  bool loading = false;
  String? loadError;

  @override
  void initState() {
    super.initState();
    loadRoles();
  }

  Future<void> loadRoles() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final fetchedRoles = await fetchRoles(); // company-scoped in service
      setState(() {
        roles = fetchedRoles;
      });
    } catch (e) {
      setState(() {
        loadError = 'Failed to load roles';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load roles')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addOrEditRole({RoleModel? existing}) async {
    final changed = await showDialog<RoleModel>(
      context: context,
      builder: (_) => AddRoleDialog(role: existing),
    );
    if (changed != null) {
      await loadRoles(); // refresh from server
    }
  }

  Future<void> _deleteRole(RoleModel role) async {
    if (role.id == null || role.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing role id; cannot delete.")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text(
          "Are you sure you want to delete the role '${role.name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await deleteRoles([role.id!]);
    if (ok) {
      await loadRoles();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Role deleted")));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete role")));
    }
  }

  Widget _icon(bool val) => Icon(
    val ? Icons.check : Icons.close,
    color: val ? Colors.green : Colors.red,
  );

  @override
  Widget build(BuildContext context) {
    final filteredRoles = roles
        .where(
          (r) => (r.name).toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Manage System Roles"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadRoles),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (q) => setState(() => searchQuery = q),
            ),
          ),
          if (loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (loadError != null)
            Expanded(
              child: Center(
                child: Text(
                  loadError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredRoles.length,
                itemBuilder: (_, index) {
                  final role = filteredRoles[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        role.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              "All Location Access: ",
                              style: TextStyle(color: Colors.white70),
                            ),
                            _icon(role.allLocationAccess),
                            const SizedBox(width: 20),
                            const Text(
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
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFFCC737),
                            ),
                            onPressed: () => _addOrEditRole(existing: role),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
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
        backgroundColor: const Color(0xFFFCC737),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

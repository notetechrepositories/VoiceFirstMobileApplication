// views/add_role.dart
import 'package:flutter/material.dart';
import '../../Models/permission_model.dart';

class AddRoleDialog extends StatefulWidget {
  final RoleModel? role;

  AddRoleDialog({this.role});

  @override
  _AddRoleDialogState createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  final _controller = TextEditingController();
  bool allLocationAccess = false;
  bool allIssueAccess = false;
  List<String> modules = ['User', 'Company'];
  late List<PermissionModel> permissions;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      final r = widget.role!;
      _controller.text = r.name;
      allLocationAccess = r.allLocationAccess;
      allIssueAccess = r.allIssueAccess;
      permissions = r.permissions
          .map(
            (p) => PermissionModel(
              module: p.module,
              create: p.create,
              read: p.read,
              update: p.update,
              delete: p.delete,
              updateFromExcel: p.updateFromExcel,
              downloadExcel: p.downloadExcel,
              downloadPdf: p.downloadPdf,
            ),
          )
          .toList();
    } else {
      permissions = modules.map((m) => PermissionModel(module: m)).toList();
    }
  }

  Widget _checkbox(String label, bool value, void Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: (val) => onChanged(val!)),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        widget.role == null ? "Add Role" : "Edit Role",
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Role Name",
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            CheckboxListTile(
              title: Text(
                "All Location Access",
                style: TextStyle(color: Colors.white),
              ),
              value: allLocationAccess,
              onChanged: (val) => setState(() => allLocationAccess = val!),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text(
                "All Issue Access",
                style: TextStyle(color: Colors.white),
              ),
              value: allIssueAccess,
              onChanged: (val) => setState(() => allIssueAccess = val!),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            Divider(color: Colors.white24),
            Text(
              "Permissions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ...permissions.map(
              (perm) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(perm.module, style: TextStyle(color: Colors.white)),
                  Wrap(
                    spacing: 8,
                    children: [
                      _checkbox(
                        "Create",
                        perm.create,
                        (v) => setState(() => perm.create = v),
                      ),
                      _checkbox(
                        "Read",
                        perm.read,
                        (v) => setState(() => perm.read = v),
                      ),
                      _checkbox(
                        "Update",
                        perm.update,
                        (v) => setState(() => perm.update = v),
                      ),
                      _checkbox(
                        "Delete",
                        perm.delete,
                        (v) => setState(() => perm.delete = v),
                      ),
                      _checkbox(
                        "Update Excel",
                        perm.updateFromExcel,
                        (v) => setState(() => perm.updateFromExcel = v),
                      ),
                      _checkbox(
                        "Download Excel",
                        perm.downloadExcel,
                        (v) => setState(() => perm.downloadExcel = v),
                      ),
                      _checkbox(
                        "Download PDF",
                        perm.downloadPdf,
                        (v) => setState(() => perm.downloadPdf = v),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white24),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFCC737),
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            final role = RoleModel(
              name: _controller.text.trim(),
              allLocationAccess: allLocationAccess,
              allIssueAccess: allIssueAccess,
              permissions: permissions,
            );
            Navigator.pop(context, role);
          },
          child: Text("Submit"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Models/permission_model.dart';
import '../../Models/program_model.dart';
import '../../Models/role_model.dart';

class AddRoleDialog extends StatefulWidget {
  final RoleModel? role;

  const AddRoleDialog({this.role});

  @override
  State<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  final _controller = TextEditingController();
  bool allLocationAccess = false;
  bool allIssueAccess = false;

  List<ProgramModel> availablePrograms = [];
  List<ProgramPermissionModel> permissions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final url = Uri.parse("http://192.168.0.111:8022/api/programs");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List programs = data["data"];

        availablePrograms = programs
            .map((e) => ProgramModel.fromJson(e))
            .toList();

        if (widget.role != null) {
          _controller.text = widget.role!.name;
          allLocationAccess = widget.role!.allLocationAccess;
          allIssueAccess = widget.role!.allIssueAccess;

          permissions = availablePrograms.map((program) {
            final match = widget.role!.permissions.firstWhere(
              (p) => p.programId == program.id,
              orElse: () =>
                  ProgramPermissionModel(programId: program.id, label: ''),
            );
            return ProgramPermissionModel(
              programId: program.id,
              label: program.label,
              create: match.create,
              update: match.update,
              view: match.view,
              delete: match.delete,
              download: match.download,
              email: match.email,
              canCreate: program.create,
              canUpdate: program.update,
              canView: program.view,
              canDelete: program.delete,
              canDownload: program.download,
              canEmail: program.email,
            );
          }).toList();
        } else {
          permissions = availablePrograms
              .map(
                (program) => ProgramPermissionModel(
                  programId: program.id,
                  label: program.label,
                  canCreate: program.create,
                  canUpdate: program.update,
                  canView: program.view,
                  canDelete: program.delete,
                  canDownload: program.download,
                  canEmail: program.email,
                ),
              )
              .toList();
        }
      }
    } catch (e) {
      print("Error loading programs: $e");
    }

    setState(() => loading = false);
  }

  Widget _checkbox(
    String label,
    bool value,
    bool enabled,
    void Function(bool) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: enabled ? (val) => onChanged(val!) : null,
        ),
        Text(
          label,
          style: TextStyle(color: enabled ? Colors.white : Colors.white54),
        ),
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
      content: loading
          ? SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
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
                    onChanged: (val) =>
                        setState(() => allLocationAccess = val!),
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
                    "Program Permissions",
                    style: TextStyle(color: Colors.white),
                  ),
                  ...permissions.map(
                    (perm) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perm.label ?? perm.programId,
                          style: TextStyle(color: Colors.white70),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            _checkbox(
                              "Create",
                              perm.create,
                              perm.canCreate,
                              (v) => setState(() => perm.create = v),
                            ),
                            _checkbox(
                              "Update",
                              perm.update,
                              perm.canUpdate,
                              (v) => setState(() => perm.update = v),
                            ),
                            _checkbox(
                              "View",
                              perm.view,
                              perm.canView,
                              (v) => setState(() => perm.view = v),
                            ),
                            _checkbox(
                              "Delete",
                              perm.delete,
                              perm.canDelete,
                              (v) => setState(() => perm.delete = v),
                            ),
                            _checkbox(
                              "Download",
                              perm.download,
                              perm.canDownload,
                              (v) => setState(() => perm.download = v),
                            ),
                            _checkbox(
                              "Email",
                              perm.email,
                              perm.canEmail,
                              (v) => setState(() => perm.email = v),
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
              status: true,
            );
            Navigator.pop(context, role);
          },
          child: Text("Submit"),
        ),
      ],
    );
  }
}

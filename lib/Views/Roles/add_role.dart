import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Core/Services/api_client.dart';
import '../../Models/permission_model.dart';
import '../../Models/program_model.dart';
import '../../Models/role_model.dart';

class AddRoleDialog extends StatefulWidget {
  final RoleModel? role;

  const AddRoleDialog({super.key, this.role});

  @override
  State<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  final _controller = TextEditingController();
  bool allLocationAccess = false;
  bool allIssueAccess = false;

  final Dio _dio = ApiClient().dio;

  List<ProgramModel> availablePrograms = [];
  List<ProgramPermissionModel> permissions = [];

  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final res = await _dio.get('/programs');
      final List<dynamic> programs = (res.data['data'] as List<dynamic>);
      availablePrograms = programs
          .map((e) => ProgramModel.fromJson(e))
          .toList();

      // Seed permissions list; merge existing role-permissions when editing
      permissions = availablePrograms.map((program) {
        final existing = widget.role?.permissions.firstWhere(
          (p) => p.programId == program.id,
          orElse: () => ProgramPermissionModel(
            programId: program.id,
            label: program.label,
          ),
        );

        return ProgramPermissionModel(
          id: existing?.id,
          programId: program.id,
          label: program.label,
          // current values (what the user can toggle)
          create: existing?.create ?? false,
          update: existing?.update ?? false,
          view: existing?.view ?? false,
          delete: existing?.delete ?? false,
          download: existing?.download ?? false,
          email: existing?.email ?? false,
          // capability flags (enable/disable checkboxes)
          canCreate: program.create,
          canUpdate: program.update,
          canView: program.view,
          canDelete: program.delete,
          canDownload: program.download,
          canEmail: program.email,
        );
      }).toList();

      if (widget.role != null) {
        _controller.text = widget.role!.name;
        allLocationAccess = widget.role!.allLocationAccess;
        allIssueAccess = widget.role!.allIssueAccess;
      }
    } on DioException catch (e) {
      debugPrint('Error loading programs: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load programs')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
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

  Future<void> _submitRole() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role name cannot be empty')),
      );
      return;
    }

    final role = RoleModel(
      id: widget.role?.id, // null → POST, non-null → PUT
      name: name,
      allLocationAccess: allLocationAccess,
      allIssueAccess: allIssueAccess,
      permissions: permissions,
      status: true,
    );

    setState(() => submitting = true);

    try {
      final body = role.toJson(includeIds: widget.role != null);

      final Response res = widget.role == null
          ? await _dio.post('/roles', data: body)
          : await _dio.put('/roles', data: body);

      // Treat 2xx as success
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        if (!mounted) return;
        Navigator.pop(context, role);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Role saved')));
      } else {
        final msg = (res.data is Map && res.data['message'] != null)
            ? res.data['message'].toString()
            : 'Failed to save role';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response!.data['message'].toString()
          : 'Error submitting role';
      debugPrint('Submit role error: ${e.response?.data ?? e.message}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        widget.role == null ? 'Add Role' : 'Edit Role',
        style: const TextStyle(color: Colors.white),
      ),
      content: loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Role Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'All Location Access',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: allLocationAccess,
                    onChanged: (val) =>
                        setState(() => allLocationAccess = val!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'All Issue Access',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: allIssueAccess,
                    onChanged: (val) => setState(() => allIssueAccess = val!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const Divider(color: Colors.white24),
                  const Text(
                    'Program Permissions',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  ...permissions.map(
                    (perm) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perm.label ?? perm.programId,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            _checkbox(
                              'Create',
                              perm.create,
                              perm.canCreate,
                              (v) => setState(() => perm.create = v),
                            ),
                            _checkbox(
                              'Update',
                              perm.update,
                              perm.canUpdate,
                              (v) => setState(() => perm.update = v),
                            ),
                            _checkbox(
                              'View',
                              perm.view,
                              perm.canView,
                              (v) => setState(() => perm.view = v),
                            ),
                            _checkbox(
                              'Delete',
                              perm.delete,
                              perm.canDelete,
                              (v) => setState(() => perm.delete = v),
                            ),
                            _checkbox(
                              'Download',
                              perm.download,
                              perm.canDownload,
                              (v) => setState(() => perm.download = v),
                            ),
                            _checkbox(
                              'Email',
                              perm.email,
                              perm.canEmail,
                              (v) => setState(() => perm.email = v),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFCC737),
            foregroundColor: Colors.black,
          ),
          onPressed: submitting ? null : _submitRole,
          child: submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

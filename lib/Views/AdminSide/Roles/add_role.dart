import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../Core/Services/api_client.dart';
import '../../../Models/permission_model.dart';
import '../../../Models/program_model.dart';
import '../../../Models/role_model.dart';

class AddRoleDialog extends StatefulWidget {
  final RoleModel? role;
  const AddRoleDialog({super.key, this.role});

  @override
  State<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  final _controller = TextEditingController();
  bool allLocationAccess = false;
  bool allIssueAccess = false; // maps to allIssuesAccess in payload

  final Dio _dio = ApiClient().dio;

  List<ProgramModel> availablePrograms = [];
  List<ProgramPermissionModel> permissions = [];

  bool loading = true;
  bool submitting = false;

  // ULID validator (26 chars, Crockford Base32)
  final RegExp _ulidRe = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$');
  bool _isUlid(String? s) => s != null && _ulidRe.hasMatch(s);

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final res = await _dio.get(
        '/programs',
        options: Options(extra: {'auth': 'company'}),
      );
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
          // current values
          create: existing?.create ?? false,
          update: existing?.update ?? false,
          view: existing?.view ?? false,
          delete: existing?.delete ?? false,
          download: existing?.download ?? false,
          email: existing?.email ?? false,
          // UI-only capability flags
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load programs')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // Build rolePrograms array with only rows that have at least one true flag.
  List<Map<String, dynamic>> _buildRolePrograms({required bool includeIds}) {
    bool _anyTrue(ProgramPermissionModel p) =>
        p.create || p.update || p.view || p.delete || p.download || p.email;

    return permissions.where(_anyTrue).map((p) {
      final m = <String, dynamic>{
        'programId': p.programId,
        'create': p.create,
        'update': p.update,
        'view': p.view,
        'delete': p.delete,
        'download': p.download,
        'email': p.email,
      };
      // Include child id only if updating AND it's a valid ULID
      if (includeIds && _isUlid(p.id)) {
        m['id'] = p.id;
      }
      return m;
    }).toList();
  }

  // Build server-compliant payloads
  Map<String, dynamic> _buildPostPayload({required String roleName}) {
    return {
      'roleName': roleName,
      'allLocationAccess': allLocationAccess,
      'allIssuesAccess': allIssueAccess, // plural as per API
      'rolePrograms': _buildRolePrograms(includeIds: false),
      // DO NOT include top-level id or status for POST (per spec)
    };
  }

  Map<String, dynamic> _buildPutPayload({
    required String id,
    required String roleName,
  }) {
    return {
      'id': id, // required and must be a valid ULID
      'roleName': roleName,
      'allLocationAccess': allLocationAccess,
      'allIssuesAccess': allIssueAccess,
      'rolePrograms': _buildRolePrograms(includeIds: true),
      // DO NOT include status unless API explicitly allows it
    };
  }

  Future<void> _submitRole() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role name cannot be empty')),
      );
      return;
    }

    final rp = _buildRolePrograms(includeIds: widget.role != null);
    if (rp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one permission for a program'),
        ),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      late final Response res;

      if (widget.role == null) {
        // CREATE — per API spec for POST
        final payload = _buildPostPayload(roleName: name);
        res = await _dio.post(
          '/roles',
          data: payload,
          options: Options(extra: {'auth': 'company'}),
        );
      } else {
        // UPDATE — API spec shows id in BODY (PUT /roles)
        final id = widget.role!.id;
        if (!_isUlid(id)) {
          throw DioException(
            requestOptions: RequestOptions(path: '/roles'),
            error: 'Role id is missing or not a valid ULID',
          );
        }
        final payload = _buildPutPayload(id: id!, roleName: name);
        res = await _dio.put(
          '/roles', // << use body id per your spec, not /roles/{id}
          data: payload,
          options: Options(extra: {'auth': 'company'}),
        );
      }

      final ok =
          res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300;
      if (ok && mounted) {
        // Build local model to pass back (UI only)
        final role = RoleModel(
          id: widget.role?.id ?? (res.data?['data']?['id'] as String?),
          name: name,
          allLocationAccess: allLocationAccess,
          allIssueAccess: allIssueAccess,
          permissions: permissions,
          status: true,
        );
        Navigator.pop(context, role);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Role saved')));
      } else {
        final msg = (res.data is Map && res.data['message'] != null)
            ? res.data['message'].toString()
            : 'Failed to save role';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } on DioException catch (e) {
      String msg = 'Error submitting role';
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        msg = data['message'].toString();
      } else if (e.message != null) {
        msg = e.message!;
      }
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

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:voicefirst/Core/Constants/api_endpoins.dart';

// class EditDivisionThreeDialog extends StatefulWidget {
//   final String initialValue;
//   final String id;
//   final Color cardColor;
//   final Color textPrimary;
//   final Color textSecondary;
//   final Color accentColor;
//   final VoidCallback onSuccess;

//   const EditDivisionThreeDialog({
//     super.key,
//     required this.initialValue,
//     required this.id,
//     required this.cardColor,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.accentColor,
//     required this.onSuccess,
//   });

//   @override
//   State<EditDivisionThreeDialog> createState() =>
//       _EditDivisionThreeDialogState();
// }

// class _EditDivisionThreeDialogState extends State<EditDivisionThreeDialog> {
//   late TextEditingController _controller;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialValue);
//   }

//   Future<void> _save() async {
//     final newValue = _controller.text.trim();
//     if (newValue.isEmpty || newValue == widget.initialValue) {
//       Navigator.pop(context);
//       return;
//     }

//     setState(() => _isLoading = true);

//     final success = await _updateDivisionThree(widget.id, newValue);
//     setState(() => _isLoading = false);

//     Navigator.pop(context);
//     if (success) {
//       widget.onSuccess();
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Division Three updated')));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update Division Three')),
//       );
//     }
//   }

//   Future<bool> _updateDivisionThree(String id, String value) async {
//     final url = Uri.parse('${ApiEndpoints.baseUrl}/division-three');

//     try {
//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({"id": id, "divisionThree": value}),
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         return json['isSuccess'] == true;
//       } else {
//         debugPrint('API error: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Exception: $e');
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: widget.cardColor,
//       title: Text(
//         'Edit Division Three',
//         style: TextStyle(color: widget.accentColor),
//       ),
//       content: TextField(
//         controller: _controller,
//         style: TextStyle(color: widget.textPrimary),
//         decoration: InputDecoration(
//           labelText: 'Division Three',
//           labelStyle: TextStyle(color: widget.textSecondary),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
//         ),
//         TextButton(
//           onPressed: _isLoading ? null : _save,
//           child: Text('Save', style: TextStyle(color: widget.accentColor)),
//         ),
//       ],
//     );
//   }
// }

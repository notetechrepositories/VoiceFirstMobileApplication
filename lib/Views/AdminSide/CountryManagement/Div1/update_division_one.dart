// //to be done

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:voicefirst/Core/Constants/api_endpoins.dart';

// class EditDivisionOneDialog extends StatefulWidget {
//   final String initialValue;
//   final String id;
//   final Color cardColor;
//   final Color textPrimary;
//   final Color textSecondary;
//   final Color accentColor;
//   final VoidCallback onSuccess;

//   const EditDivisionOneDialog({
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
//   State<EditDivisionOneDialog> createState() => _EditDivisionOneDialogState();
// }

// class _EditDivisionOneDialogState extends State<EditDivisionOneDialog> {
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

//     final success = await _updateDivisionOne(widget.id, newValue);
//     setState(() => _isLoading = false);

//     Navigator.pop(context);
//     if (success) {
//       widget.onSuccess();
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Division One updated')));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update Division One')),
//       );
//     }
//   }

//   Future<bool> _updateDivisionOne(String id, String value) async {
//     final url = Uri.parse('${ApiEndpoints.baseUrl}/division-one');

//     try {
//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({"id": id, "divisionOne": value}),
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
//         'Edit Division One',
//         style: TextStyle(color: widget.accentColor),
//       ),
//       content: TextField(
//         controller: _controller,
//         style: TextStyle(color: widget.textPrimary),
//         decoration: InputDecoration(
//           labelText: 'Division One',
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

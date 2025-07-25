import 'package:flutter/material.dart';

class AddCountryDialog extends StatefulWidget {
  final Function({
    required String country,
    required String divisionOne,
    required String divisionTwo,
    required String divisionThree,
  })
  onSubmit;

  const AddCountryDialog({super.key, required this.onSubmit});

  @override
  State<AddCountryDialog> createState() => _AddCountryDialogState();
}

class _AddCountryDialogState extends State<AddCountryDialog> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _div1Controller = TextEditingController();
  final TextEditingController _div2Controller = TextEditingController();
  final TextEditingController _div3Controller = TextEditingController();

  final Color _accentColor = Color(0xFFFCC737);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF262626),
      title: Text('Add Country', style: TextStyle(color: _accentColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_countryController, 'Country'),
            _buildTextField(_div1Controller, 'Division One Label'),
            _buildTextField(_div2Controller, 'Division Two Label'),
            _buildTextField(_div3Controller, 'Division Three Label'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        TextButton(
          onPressed: () {
            if (_countryController.text.trim().isEmpty) return;

            widget.onSubmit(
              country: _countryController.text.trim(),
              divisionOne: _div1Controller.text.trim(),
              divisionTwo: _div2Controller.text.trim(),
              divisionThree: _div3Controller.text.trim(),
            );

            Navigator.of(context).pop();
          },
          child: Text('Add', style: TextStyle(color: _accentColor)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

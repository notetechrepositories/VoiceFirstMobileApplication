import 'package:flutter/material.dart';
import 'package:voicefirst/Core/Constants/snack_bar.dart';
import 'package:voicefirst/Models/country_model.dart';

class EditCountryDialog extends StatefulWidget {
  final CountryModel country;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onUpdated;
  final VoidCallback onCancel;
  // final VoidCallback onCancelAndShowDetail;

  const EditCountryDialog({
    super.key,
    required this.country,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.onUpdate,
    required this.onUpdated,
    required this.onCancel,
    // required this.onCancelAndShowDetail,
  });

  @override
  State<EditCountryDialog> createState() => _EditCountryDialogState();
}

class _EditCountryDialogState extends State<EditCountryDialog> {
  late TextEditingController _countryController;
  late TextEditingController _div1Controller;
  late TextEditingController _div2Controller;
  late TextEditingController _div3Controller;

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController(text: widget.country.country);
    _div1Controller = TextEditingController(
      text: widget.country.divisionOneLabel,
    );
    _div2Controller = TextEditingController(
      text: widget.country.divisionTwoLabel,
    );
    _div3Controller = TextEditingController(
      text: widget.country.divisionThreeLabel,
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    _div1Controller.dispose();
    _div2Controller.dispose();
    _div3Controller.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedData = <String, dynamic>{'id': widget.country.id};

    final newCountry = _countryController.text.trim();
    final newDiv1 = _div1Controller.text.trim();
    final newDiv2 = _div2Controller.text.trim();
    final newDiv3 = _div3Controller.text.trim();

    if (newCountry.isNotEmpty && newCountry != widget.country.country) {
      updatedData['country'] = newCountry;
    }
    if (newDiv1.isNotEmpty && newDiv1 != widget.country.divisionOneLabel) {
      updatedData['divisionOneLabel'] = newDiv1;
    }
    if (newDiv2.isNotEmpty && newDiv2 != widget.country.divisionTwoLabel) {
      updatedData['divisionTwoLabel'] = newDiv2;
    }
    if (newDiv3.isNotEmpty && newDiv3 != widget.country.divisionThreeLabel) {
      updatedData['divisionThreeLabel'] = newDiv3;
    }

    if (updatedData.length == 1) {
      Navigator.of(context).pop();
      SnackbarHelper.showSuccess('No changes to update');
      return;
    }

    final updatedCountry = await widget.onUpdate(updatedData);

    if (updatedCountry != null) {
      widget.onUpdated();
      Navigator.of(context).pop();
      SnackbarHelper.showSuccess('Country updated');
    } else {
      SnackbarHelper.showError('Failed to update country');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.cardColor,
      title: Text('Edit Country', style: TextStyle(color: widget.accentColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_countryController, 'Country Name'),
            _buildTextField(_div1Controller, 'Division One Label'),
            _buildTextField(_div2Controller, 'Division Two Label'),
            _buildTextField(_div3Controller, 'Division Three Label'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close Edit
            // widget.onCancelAndShowDetail(); // reopen Detail
          },

          child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: Text('Save', style: TextStyle(color: widget.accentColor)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: widget.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: widget.textSecondary),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCountryDialog extends StatefulWidget {
  final Function({
    required String country,
    required String countryCode,
    required String countryIsoCode,
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
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _isoCodeController = TextEditingController();
  final TextEditingController _div1Controller = TextEditingController();
  final TextEditingController _div2Controller = TextEditingController();
  final TextEditingController _div3Controller = TextEditingController();

  final Color _accentColor = Color(0xFFFCC737);
  final _formKey = GlobalKey<FormState>();

  //validations
  final _reCountryName = RegExp(r"^[A-Za-z][A-Za-z\s\-'().]{1,49}$"); // 2–50
  final _reCountryCode = RegExp(r"^\+\d{1,3}$"); // +1..+999
  final _reIso2 = RegExp(r"^[A-Za-z]{2}$"); // 2 letters
  final _reDivision = RegExp(r"^(?=.{1,40}$).+"); // 1–40 chars

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF262626),
      title: Text('Add Country', style: TextStyle(color: _accentColor)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                _countryController,
                'Country',
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Country Name is required';
                  if (!_reCountryName.hasMatch(t)) {
                    return 'Invalid country name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                _countryCodeController,
                'Country Code (Example +123)',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Country code is required';
                  if (!_reCountryCode.hasMatch(t)) {
                    return 'Use + followed by 1–3 digits (e.g. +91)';
                  }
                  return null;
                },
                maxLength: 4,
              ),
              _buildTextField(
                _isoCodeController,
                'Country ISO Code',
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'ISO code is required';
                  if (!_reIso2.hasMatch(t)) {
                    return 'Use 2 letters (e.g. IN, US)';
                  }
                  return null;
                },
              ),
              _buildTextField(
                _div1Controller,
                'Division One Label',
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  if (!_reDivision.hasMatch(t)) return 'Max 40 characters';
                  return null;
                },
                maxLength: 40,
              ),
              _buildTextField(
                _div2Controller,
                'Division Two Label',
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  if (!_reDivision.hasMatch(t)) return 'Max 40 characters';
                  return null;
                },
                maxLength: 40,
              ),
              _buildTextField(
                _div3Controller,
                'Division Three Label',
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  if (!_reDivision.hasMatch(t)) return 'Max 40 characters';
                  return null;
                },
                maxLength: 40,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        TextButton(
          onPressed: () {
            // Validate all fields
            final ok = _formKey.currentState?.validate() ?? false;
            if (!ok) return;
            // if (_countryController.text.trim().isEmpty) return;
            // Normalize before submit
            final country = _countryController.text.trim();
            final countryCode = _countryCodeController.text
                .trim(); // already “+###”
            final countryIsoCode = _isoCodeController.text
                .trim()
                .toUpperCase(); // ensure 2-letter upper
            final divisionOne = _div1Controller.text.trim();
            final divisionTwo = _div2Controller.text.trim();
            final divisionThree = _div3Controller.text.trim();

            widget.onSubmit(
              country: country,
              countryCode: countryCode,
              countryIsoCode: countryIsoCode,
              divisionOne: divisionOne,
              divisionTwo: divisionTwo,
              divisionThree: divisionThree,
            );

            Navigator.of(context).pop();
          },
          child: Text('Add', style: TextStyle(color: _accentColor)),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          counterText: '',
          labelText: null,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ).copyWith(labelText: label),
      ),
    );
  }
}

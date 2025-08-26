import 'package:flutter/material.dart';
import 'package:voicefirst/Models/country_model.dart';

class CountryDetailDialog extends StatelessWidget {
  final CountryModel country;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const CountryDetailDialog({
    super.key,
    required this.country,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardColor,
      title: Text(country.country, style: TextStyle(color: accentColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoText("Country Code: ", country.countryCode, textPrimary),
          _infoText(
            'Country ISO Code : ',
            country.countryIsoCode ?? '',
            textPrimary,
          ),
          _infoText(
            "Division One Label: ",
            country.divisionOneLabel ?? '',
            textPrimary,
          ),
          _infoText(
            "Division Two Label: ",
            country.divisionTwoLabel ?? '',
            textPrimary,
          ),
          _infoText(
            "Division Three Label: ",
            country.divisionThreeLabel ?? '',
            textPrimary,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onEdit,
          child: Text("Edit", style: TextStyle(color: accentColor)),
        ),
        TextButton(
          onPressed: onCancel,
          child: Text("Cancel", style: TextStyle(color: textSecondary)),
        ),
      ],
    );
  }

  Widget _infoText(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text('$label$value', style: TextStyle(color: textColor)),
    );
  }
}

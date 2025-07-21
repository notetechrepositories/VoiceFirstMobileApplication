// import 'package:flutter/material.dart';
// import 'package:voicefirst/Models/country_model.dart';

// class CountryDetailPage extends StatelessWidget {
//   final CountryModel country;
//   final Color bgColor;
//   final Color textPrimary;
//   final Color textSecondary;
//   final Color cardColor;

//   const CountryDetailPage({
//     super.key,
//     required this.country,
//     required this.bgColor,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.cardColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         iconTheme: IconThemeData(color: textSecondary),
//         title: Text(country.country, style: TextStyle(color: textPrimary)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           color: cardColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               _buildItem('Division 1', country.divisionOneLabel),
//               _buildItem('Division 2', country.divisionTwoLabel),
//               _buildItem('Division 3', country.divisionThreeLabel),
//               _buildItem('Status', country.status ? 'Active' : 'Inactive'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Text(
//             '$label:',
//             style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(value, style: TextStyle(color: textPrimary)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:voicefirst/Models/country_model.dart';

class CountryDetailPage extends StatelessWidget {
  final CountryModel country;
  final Future<bool> Function(String id, String divisionLevel) onDelete;
  final Color bgColor;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const CountryDetailPage({
    super.key,
    required this.country,
    required this.onDelete,
    required this.bgColor,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final divisions = [
      {
        'label': 'Division 1',
        'value': country.divisionOneLabel,
        'level': 'divisionOneLabel',
      },
      {
        'label': 'Division 2',
        'value': country.divisionTwoLabel,
        'level': 'divisionTwoLabel',
      },
      {
        'label': 'Division 3',
        'value': country.divisionThreeLabel,
        'level': 'divisionThreeLabel',
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: accentColor),
        title: Text(
          '${country.country} Divisions',
          style: TextStyle(color: textPrimary),
        ),
      ),
      body: ListView.builder(
        itemCount: divisions.length,
        itemBuilder: (context, index) {
          final division = divisions[index];
          return Card(
            color: cardColor,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                division['value'] ?? '',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                division['label']!,
                style: TextStyle(color: textSecondary),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Delete ${division['label']}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final success = await onDelete(
                      country.id,
                      division['level']!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${division['label']} deleted'
                              : 'Failed to delete',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

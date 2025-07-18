// import 'package:flutter/material.dart';

// class ViewActivityDialog extends StatelessWidget {
//   // const ViewActivityDialog({super.key});

//   final Map<String, dynamic> activity;
//   final VoidCallback onEdit;

//    final Color cardColor;
//   final Color chipColor;
//   final Color textPrimary;
//   final Color textSecondary;
//   final Color accentColor;

//   const ActivityDetailDialog({
//     super.key,
//     required this.activity,
//     required this.onEdit,
//     required this.cardColor,
//     required this.chipColor,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.accentColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final labels = <String>[];
//     if (activity['company'] == 'y') labels.add('Company');
//     if (activity['branch'] == 'y') labels.add('Branch');
//     if (activity['section'] == 'y') labels.add('Section');
//     if (activity['sub_section'] == 'y') labels.add('Sub-section');

//      return AlertDialog(
//       backgroundColor: cardColor,
//       title: Text('Activity Details', style: TextStyle(color: textPrimary)),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Name: ${activity['business_activity_name'] ?? ''}',
//             style: TextStyle(
//               color: textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text('Available in:', style: TextStyle(color: textSecondary)),
//           const SizedBox(height: 4),
//           labels.isEmpty
//               ? Text('None', style: TextStyle(color: textSecondary))
//               : Wrap(
//                   spacing: 6,
//                   runSpacing: 4,
//                   children: labels
//                       .map(
//                         (lbl) => Chip(
//                           label: Text(lbl, style: TextStyle(color: textPrimary)),
//                           backgroundColor: chipColor,
//                           padding: EdgeInsets.zero,
//                         ),
//                       )
//                       .toList(),
//                 ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             onEdit();
//           },
//           child: Text('Edit', style: TextStyle(color: accentColor)),
//         ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: Text('Close', style: TextStyle(color: accentColor)),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class ViewActivityDialog extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onEdit;

  final Color cardColor;
  final Color chipColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const ViewActivityDialog({
    super.key,
    required this.activity,
    required this.onEdit,
    required this.cardColor,
    required this.chipColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[];
    if (activity['company'] == 'y') labels.add('Company');
    if (activity['branch'] == 'y') labels.add('Branch');
    if (activity['section'] == 'y') labels.add('Section');
    if (activity['sub_section'] == 'y') labels.add('Sub-section');

    return AlertDialog(
      backgroundColor: cardColor,
      title: Text('Activity Details', style: TextStyle(color: textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${activity['business_activity_name'] ?? ''}',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('Available in:', style: TextStyle(color: textSecondary)),
          const SizedBox(height: 4),
          labels.isEmpty
              ? Text('None', style: TextStyle(color: textSecondary))
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: labels
                      .map(
                        (lbl) => Chip(
                          label: Text(
                            lbl,
                            style: TextStyle(color: textPrimary),
                          ),
                          backgroundColor: chipColor,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onEdit();
          },
          child: Text('Edit', style: TextStyle(color: accentColor)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: accentColor)),
        ),
      ],
    );
  }
}

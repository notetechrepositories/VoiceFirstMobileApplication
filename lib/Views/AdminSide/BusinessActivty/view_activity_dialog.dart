import 'package:flutter/material.dart';
import 'package:voicefirst/Models/business_activity_model1.dart';

class ViewActivityDialog extends StatelessWidget {
  final BusinessActivity activity;
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
    if (activity.isForCompany) labels.add('Company');
    if (activity.isForBranch) labels.add('Branch');
    // if (activity['section'] == 'y') labels.add('Section');
    // if (activity['sub_section'] == 'y') labels.add('Sub-section');
    final isActive = activity.status;

    return AlertDialog(
      backgroundColor: cardColor,
      title: Text('Activity Details', style: TextStyle(color: textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${activity.activityName}',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Available in:',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          labels.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('None', style: TextStyle(color: textSecondary)),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: labels.map((lbl) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lbl,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
          // SizedBox(height: 12),
          const SizedBox(height: 5),

          // Activity Status
          Row(
            children: [
              Text(
                'Status: ',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                child: Text(
                  isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: isActive ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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

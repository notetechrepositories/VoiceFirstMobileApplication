import 'package:flutter/material.dart';

class ArrowBreadcrumb extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;
  final Function(int) onTap;

  const ArrowBreadcrumb({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 4),
      // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: List.generate(steps.length, (index) {
          final isCurrent = index == currentIndex;
          final isLast = index == steps.length - 1;

          return Row(
            children: [
              GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFFFCC737)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFCC737),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      color: isCurrent ? Colors.black : const Color(0xFFFCC737),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (!isLast) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
              ],
            ],
          );
        }),
      ),
    );
  }
}

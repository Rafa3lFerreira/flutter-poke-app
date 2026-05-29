import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label   $value / $maxValue',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
          SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final ratio = (value / maxValue).clamp(0.0, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

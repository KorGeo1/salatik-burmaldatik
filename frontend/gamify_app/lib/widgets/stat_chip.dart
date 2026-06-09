import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Маленький чип со статом (монеты / XP / стрик)
class StatChip extends StatelessWidget {
  final IconData? icon;   // используется если emoji == null
  final String? emoji;    // приоритет над icon
  final Color color;
  final String value;
  final String label;

  const StatChip({
    super.key,
    this.icon,
    this.emoji,
    required this.color,
    required this.value,
    required this.label,
  }) : assert(icon != null || emoji != null, 'Укажи icon или emoji');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Иконка: эмодзи или Material icon
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 17, height: 1))
          else
            Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
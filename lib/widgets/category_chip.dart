import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center, // CRITICAL: Centers text vertically & horizontally
        padding: const EdgeInsets.symmetric(
          horizontal: 25, // Increased for a better "pill" look
        ),
        margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white, // Using white to match the new clean look
          borderRadius: BorderRadius.circular(50), // Fully round pill
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 50, offset: const Offset(0, 5))]
              : [],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13, // Slightly smaller for professional feel
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.black // Assuming primary yellow background, black text is more readable
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
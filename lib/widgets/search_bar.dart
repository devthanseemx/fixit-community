import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    this.hintText = "Search problems, solutions...",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use a subtle shadow instead of a heavy border to make it visible on white
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.black45),
          filled: true,
          fillColor: Colors.white, // Pure white background
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

          // These borders prevent the "overlapping" box look
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
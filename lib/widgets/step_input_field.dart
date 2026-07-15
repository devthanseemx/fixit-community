import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StepInputField extends StatelessWidget {
  final int stepNumber;
  final TextEditingController controller;
  final VoidCallback onRemove;

  const StepInputField({
    super.key,
    required this.stepNumber,
    required this.controller,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The Auto-Number Circle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$stepNumber",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // The Input Field
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Describe step $stepNumber...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
            ),
          ),
          // Remove button (only show if it's not the first step)
          if (stepNumber > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
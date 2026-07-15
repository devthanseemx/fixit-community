import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProblemDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String userName;
  final String timeStamp;

  const ProblemDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.userName,
    required this.timeStamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Problem Details", style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 15),

            // Full Title
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 10),

            // User and Date
            Row(
              children: [
                Text("@$userName", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(width: 10),
                const Icon(Icons.circle, size: 4, color: Colors.grey),
                const SizedBox(width: 10),
                Text(timeStamp, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 40, thickness: 1, color: Color(0xFFF5F5F5)),

            // Full Description Section
            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
            ),
            const SizedBox(height: 30),

            // Fixing Steps Placeholder
            const Text("Fixing Steps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStep(1, "Ensure all cables are connected properly."),
            _buildStep(2, "Restart your device and check for updates."),
            _buildStep(3, "Contact system administrator if the issue persists."),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$number. ", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }
}
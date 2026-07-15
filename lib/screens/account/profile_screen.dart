import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/notification.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController(text: "Alex Thompson");
  final TextEditingController _usernameController = TextEditingController(text: "alex_tech");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile Settings",
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROFILE IMAGE SECTION ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "@${_usernameController.text}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- FULL NAME ---
            const Text(
                "Full Name",
                style: TextStyle(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration("Enter your full name"),
            ),

            const SizedBox(height: 20),

            // --- USERNAME ---
            const Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: _inputDecoration("Enter username").copyWith(
                prefixText: "@ ",
                prefixStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- UPDATE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logic to update profile
                  setState(() {}); // Refresh UI to update the @name under avatar
                  AppMessages.showSuccess(context, "Profile updated successfully!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                ),
                child: const Text(
                    "Update Profile",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFF5F5F5), thickness: 2),
            const SizedBox(height: 24),

            // --- DANGER ZONE ---
            const Text(
              "Account Actions",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text(
                      "Delete Account",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.redAccent),
                  ],
                ),
              ),
            ),

            // Large padding at bottom so navbar doesn't hide content
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // Consistent Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Account?"),
        content: const Text("All your posts and data will be permanently removed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppMessages.showAlert(context, "Account deleted.");
            },
            child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}
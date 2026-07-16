import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../services/data_service.dart';
import '../../widgets/notification.dart';
import '../authentication/username_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // The username as it currently exists in Firestore (the document ID).
  // Used to detect whether the user actually changed their username.
  String? _originalUsername;

  bool _isLoading = true; // Fetching the existing profile
  bool _isSaving = false; // Saving the profile update
  bool _isDeleting = false; // Deleting the account
  bool _isUploadingImage = false; // Picking/saving a profile picture

  // Base64-encoded profile picture (null = no picture set).
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // --- Load the current user's data from Firestore + local storage ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    // No local session -> send the user back to the username screen.
    if (username == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UsernameScreen()),
      );
      return;
    }

    try {
      final data = await DataService.loadUserProfile(username);

      if (!mounted) return;

      if (data != null) {
        _usernameController.text = (data['username'] ?? username).toString();
        _nameController.text = (data['fullName'] ?? '').toString();
        _profileImageBase64 = data['profileImage'] as String?;
      } else {
        // Profile missing but we still have a local session.
        _usernameController.text = username;
      }
      _originalUsername = _usernameController.text.trim().toLowerCase();
    } catch (e) {
      if (!mounted) return;
      AppMessages.showAlert(context, "Could not load profile: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Update the profile in Firestore ---
  Future<void> _updateProfile() async {
    final newName = _nameController.text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // collapse extra spaces
    // Username cannot be changed after account creation, so we always use the
    // original (already lowercase) value. Normalized defensively regardless.
    final newUsername = (_originalUsername ?? _usernameController.text.trim())
        .toLowerCase();

    // Name validation
    if (newName.isEmpty) {
      AppMessages.showAlert(context, "Please enter your full name.");
      return;
    }
    if (newName.length < 2) {
      AppMessages.showAlert(context, "Name must be at least 2 characters.");
      return;
    }
    // Letters and spaces only — no numbers or symbols of any kind.
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(newName)) {
      AppMessages.showAlert(context,
          "Name can only contain letters and spaces.");
      return;
    }

    // Username validation (safety net; the field is disabled in the UI)
    if (newUsername.isEmpty) {
      AppMessages.showAlert(context, "Please enter a username.");
      return;
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(newUsername)) {
      AppMessages.showAlert(
          context, "Username may only use lowercase letters, numbers and _");
      return;
    }

    if (_originalUsername == null) {
      AppMessages.showAlert(context, "Profile is still loading, try again.");
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Username is fixed at sign-up (the field is disabled), so we only
      // ever update the current document.
      final updates = <String, dynamic>{'fullName': newName};
      if (_profileImageBase64 != null) {
        updates['profileImage'] = _profileImageBase64;
      }

      await DataService.saveUserProfile(newUsername, updates);

      if (!mounted) return;
      setState(() {}); // Refresh the @username label under the avatar
      AppMessages.showSuccess(context, "Profile updated successfully!");
    } catch (e) {
      if (!mounted) return;
      AppMessages.showAlert(context, "Update failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Delete the account from Firestore + local storage, then log out ---
  Future<void> _deleteAccount() async {
    final username = _originalUsername ??
        (await SharedPreferences.getInstance()).getString('username');
    if (username == null) return;

    setState(() => _isDeleting = true);

    try {
      await DataService.deleteUser(username);

      // Clear the local session.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');

      if (!mounted) return;

      // Confirm the deletion, then automatically return to the
      // username screen after a short delay so the toast is visible.
      AppMessages.showSuccess(context, "Account deleted successfully.");
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UsernameScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      AppMessages.showAlert(context, "Failed to delete account: ${e.toString()}");
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initial = (_nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()[0]
            : _usernameController.text.trim())
        .toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile Settings",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: _profileImageBase64 != null
                          ? MemoryImage(
                              base64Decode(_profileImageBase64!))
                          : null,
                      child: _profileImageBase64 == null
                          ? (_isUploadingImage
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: AppColors.primary),
                                )
                              : Text(
                                  initial.isEmpty ? "?" : initial,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ))
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "@${_usernameController.text.trim()}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- FULL NAME ---
            const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: !_isSaving && !_isDeleting,
              decoration: _inputDecoration("Enter your full name"),
            ),

            const SizedBox(height: 20),

            // --- USERNAME ---
            const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              // Username is set once at sign-up and cannot be changed later.
              enabled: false,
              decoration: _inputDecoration("Enter username").copyWith(
                prefixText: "@ ",
                prefixStyle: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              "Your username is set at sign-up and can't be changed.",
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),

            const SizedBox(height: 40),

            // --- UPDATE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving || _isDeleting ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.black),
                      )
                    : const Text("Update Profile",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFF5F5F5), thickness: 2),
            const SizedBox(height: 24),

            // --- DANGER ZONE ---
            const Text(
              "Account Actions",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _isDeleting ? null : () => _showDeleteDialog(context),
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
                          color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.redAccent),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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

  // --- Pick a profile picture, compress it and save as base64 in Firestore ---
  Future<void> _pickProfileImage() async {
    if (_originalUsername == null) {
      AppMessages.showAlert(context, "Profile is still loading, try again.");
      return;
    }

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (picked == null) return; // User cancelled

    setState(() => _isUploadingImage = true);

    try {
      final bytes = await picked.readAsBytes();
      // Hold the image in memory only — it is persisted to Firestore
      // only when the user taps "Update Profile".
      _profileImageBase64 = base64Encode(bytes);

      if (!mounted) return;
      setState(() {}); // Show the new picture immediately in the avatar
      AppMessages.showInfo(context, "Picture selected — tap Update Profile to save.");
    } catch (e) {
      if (!mounted) return;
      AppMessages.showAlert(
          context, "Could not load picture: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // --- Delete confirmation dialog (Yes / No) ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Account?"),
        content: const Text(
            "All your data will be permanently removed. This action cannot be undone."),
        actions: [
          // NO -> just close and inform the user nothing happened
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppMessages.showAlert(context, "Account not deleted.");
            },
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          // YES -> delete the account and log out
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text("Yes",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

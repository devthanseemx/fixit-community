import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../services/data_service.dart';
import '../../widgets/step_input_field.dart';
import '../../widgets/notification.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  // Categories loaded from Firestore (seeded with "Other").
  List<String> _categories = [];
  String? _selectedCategory;

  bool _isLoadingCategories = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Load categories via the data service (seeds defaults if empty) ---
  Future<void> _loadCategories() async {
    try {
      _categories = await DataService.loadCategories();
    } catch (e) {
      if (!mounted) return;
      AppMessages.showAlert(context, "Could not load categories: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  void _addNewStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepControllers.removeAt(index);
    });
  }

  // --- Post the problem to Firestore, linked to the signed-in user ---
  Future<void> _postProblem() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (title.isEmpty) {
      AppMessages.showAlert(context, "Please enter a problem title.");
      return;
    }
    if (_selectedCategory == null) {
      AppMessages.showAlert(context, "Please select a category.");
      return;
    }
    if (description.isEmpty) {
      AppMessages.showAlert(context, "Please enter a description.");
      return;
    }

    setState(() => _isPosting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      if (username == null) {
        if (!mounted) return;
        AppMessages.showAlert(context, "Session expired. Please log in again.");
        setState(() => _isPosting = false);
        return;
      }

      // Fetch the display name (denormalized so the card can show it).
      String authorName = username;
      final profile = await DataService.loadUserProfile(username);
      final name = profile?['fullName'] as String?;
      if (profile != null && name != null && name.trim().isNotEmpty) {
        authorName = name.trim();
      }

      await DataService.addProblem({
        'title': title,
        'description': description,
        'category': _selectedCategory,
        'steps': steps,
        'authorUsername': username,
        'authorName': authorName,
      });

      if (!mounted) return;
      AppMessages.showSuccess(context, "Problem posted successfully!");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppMessages.showAlert(context, "Failed to post: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Post a Problem",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROBLEM TITLE ---
            const Text("Problem Title",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !_isPosting,
              decoration: _inputDecoration("e.g. My laptop screen is flickering"),
            ),

            const SizedBox(height: 20),

            // --- CATEGORY SELECTION (loaded from Firestore) ---
            const Text("Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            Theme(
              data: Theme.of(context).copyWith(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 55),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 48,
                  maxWidth: MediaQuery.of(context).size.width - 48,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                tooltip: "Select Category",
                child: InputDecorator(
                  decoration: _inputDecoration(""),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? "Select Category",
                        style: TextStyle(
                          color: _selectedCategory == null
                              ? Colors.black38
                              : Colors.black87,
                          fontSize: _selectedCategory == null ? 14 : 15,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary),
                    ],
                  ),
                ),
                itemBuilder: (context) => _categories.map((cat) {
                  return PopupMenuItem<String>(
                    value: cat,
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(cat, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  );
                }).toList(),
                onSelected: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- DESCRIPTION ---
            const Text("Problem Description",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              enabled: !_isPosting,
              maxLines: 4,
              decoration: _inputDecoration("Describe what happened in detail..."),
            ),

            const SizedBox(height: 30),

            // --- FIXING STEPS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Fixing Steps (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _isPosting ? null : _addNewStep,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Step"),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ..._stepControllers.asMap().entries.map((entry) {
              return StepInputField(
                stepNumber: entry.key + 1,
                controller: entry.value,
                onRemove: () => _removeStep(entry.key),
              );
            }),

            const SizedBox(height: 40),

            // --- POST BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postProblem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isPosting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.black),
                      )
                    : const Text("Post Problem",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Unified decoration for all boxes
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
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
}

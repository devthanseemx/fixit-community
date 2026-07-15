import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/step_input_field.dart';
import '../../widgets/notification.dart';

class AddProblemScreen extends StatefulWidget {
  const AddProblemScreen({super.key});

  @override
  State<AddProblemScreen> createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  final List<String> _categories = [
    "Electronics",
    "Computer",
    "Mobile",
    "Home Repair",
  ];

  String? _selectedCategory;

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

  @override
  Widget build(BuildContext context) {
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
            const Text("Problem Title", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(decoration: _inputDecoration("e.g. My laptop screen is flickering")),

            const SizedBox(height: 20),

            // --- CATEGORY SELECTION (USING POPUPMENU FOR THE FLOATING GAP) ---
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            Theme(
              data: Theme.of(context).copyWith(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: PopupMenuButton<String>(
                // This creates the physical GAP (Vertical offset)
                offset: const Offset(0, 55),
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 48,
                  maxWidth: MediaQuery.of(context).size.width - 48,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                tooltip: "Select Category",

                // This builds the "Box" the user clicks on
                child: InputDecorator(
                  decoration: _inputDecoration(""),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? "Select Category",
                        style: TextStyle(
                          color: _selectedCategory == null ? Colors.black38 : Colors.black87,
                          fontSize: _selectedCategory == null ? 14 : 15,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                    ],
                  ),
                ),

                // This builds the floating list
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
            const Text("Problem Description", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: _inputDecoration("Describe what happened in detail..."),
            ),

            const SizedBox(height: 30),

            // --- FIXING STEPS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Fixing Steps (Optional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addNewStep,
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
                onPressed: () {
                  if (_selectedCategory == null) {
                    AppMessages.showAlert(context, "Please select a category!");
                    return;
                  }
                  AppMessages.showSuccess(context, "Problem posted successfully!");
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Post Problem", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
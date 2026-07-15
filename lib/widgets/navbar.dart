import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navButton(
                        icon: Icons.home_outlined,
                        index: 0,
                      ),
                      const SizedBox(width: 8),
                      // CENTER PLUS BUTTON
                      _navButton(
                        icon: Icons.add,
                        index: 1,
                      ),
                      const SizedBox(width: 8),
                      _navButton(
                        icon: Icons.person_outline_rounded,
                        index: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required int index,
    bool isPrimary = false,
  }) {
    bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          // If it's the primary "Add" button, we can give it a distinct look
          // or keep it consistent with your black theme
          color: selected ? Colors.black : (isPrimary ? Colors.black.withValues(alpha: 0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: isPrimary ? 30 : 26, // Make the plus icon slightly larger
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
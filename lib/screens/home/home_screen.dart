import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/home_header.dart';
import '../../widgets/category_section.dart';
import '../../widgets/problem_card.dart';
import '../../widgets/navbar.dart';
import '../post/add_problem_screen.dart';
import '../account/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 = Home, 1 = Add (Transition), 2 = Account
  int currentIndex = 0;

  // Category State
  int selectedCategory = 0;
  final List<String> categories = [
    "All",
    "Electronics",
    "Computer",
    "Mobile",
    "Home Repair",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // This allows the body to scroll behind the glass navbar
      extendBody: true,

      // Swaps between Home Content and Account Screen
      body: _buildBody(),

      bottomNavigationBar: FloatingNavbar(
        currentIndex: currentIndex,
        onTap: (index) async {
          if (index == 1) {
            // Highlight the Plus button temporarily
            setState(() => currentIndex = 1);

            // Open the Add Screen and wait for user to return
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProblemScreen()),
            );

            // Return highlight to Home after closing Add Screen
            setState(() => currentIndex = 0);
          } else {
            // Normal navigation between Home (0) and Account (2)
            setState(() {
              currentIndex = index;
            });
          }
        },
      ),
    );
  }

  /// Decides which content to show based on the selected tab
  Widget _buildBody() {
    // If Account tab is selected
    if (currentIndex == 2) {
      return const AccountScreen();
    }

    // If Home tab is selected (or while transitioning from Add)
    return Column(
      children: [
        // 1. Header Area (Wave + Title + Search + Overlapping Categories)
        Stack(
          clipBehavior: Clip.none,
          children: [
            // The Orange Gradient Header with Wave and Fade effect
            const HomeHeader(),

            // The Categories floating over the Wave
            Positioned(
              bottom: -10, // Moves categories up into the wave area
              left: 0,
              right: 0,
              child: CategorySection(
                categories: categories,
                selectedIndex: selectedCategory,
                onCategorySelected: (index) {
                  setState(() {
                    selectedCategory = index;
                  });
                },
              ),
            ),
          ],
        ),

        // 2. Space between Categories and the List
        const SizedBox(height: 30),

        // 3. The Problem Feed
        Expanded(
          child: ListView(
            // Top padding for separation, bottom padding to clear the Floating Navbar
            padding: const EdgeInsets.only(top: 10, bottom: 130),
            children: const [
              ProblemCard(
                title: "Laptop is not turning on",
                description:
                "My laptop suddenly stopped working. The power light is blinking but the screen is black.",
                category: "Computer",
                userName: "alex_tech",
                timeStamp: "Oct 24, 10:30 AM",
              ),
              ProblemCard(
                title: "Phone battery draining quickly",
                description:
                "My phone battery drops from 100% to 20% in just two hours of normal use.",
                category: "Mobile",
                userName: "john_doe",
                timeStamp: "Oct 23, 08:15 PM",
              ),
              ProblemCard(
                title: "WiFi connection issue",
                description:
                "Internet disconnects every 10 minutes on my router. Need help with settings.",
                category: "Electronics",
                userName: "sam_fixit",
                timeStamp: "Oct 23, 02:45 PM",
              ),
              ProblemCard(
                title: "Broken AC Remote",
                description:
                "The display is working but the buttons aren't responding. Tried changing batteries.",
                category: "Home Repair",
                userName: "repair_master",
                timeStamp: "Oct 22, 11:00 AM",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
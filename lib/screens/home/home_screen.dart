import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../utils/problem_filter.dart';
import '../../services/data_service.dart';
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

  // Category State (0 = "All")
  int selectedCategory = 0;
  List<String> _dbCategories = [];

  // Search State
  String _searchQuery = '';

  // Problems loaded from the data service (Firestore or demo store)
  List<Map<String, dynamic>> _allProblems = [];
  bool _loadingProblems = true;

  List<String> get _chipCategories => ['All', ..._dbCategories];

  List<Map<String, dynamic>> get _visibleProblems {
    // Filter by category first.
    var list = _allProblems;
    if (selectedCategory != 0) {
      final cat = _chipCategories[selectedCategory];
      list = list.where((doc) {
        final d = doc;
        return (d['category'] ?? '') == cat;
      }).toList();
    }

    // Then filter by the search keyword across title, description,
    // category, author, and solution steps.
    if (_searchQuery.trim().isEmpty) return list;
    return list
        .where((doc) => problemMatchesQuery(
              doc,
              _searchQuery,
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProblems();
  }

  Future<void> _loadCategories() async {
    try {
      _dbCategories = await DataService.loadCategories();
    } catch (_) {
      // Chips will just show "All".
    }
  }

  Future<void> _loadProblems() async {
    try {
      _allProblems = await DataService.loadProblems();
    } catch (_) {
      // Feed will simply be empty on error.
    }
    if (mounted) setState(() => _loadingProblems = false);
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[d.month - 1];
    final h = d.hour == 0
        ? 12
        : (d.hour > 12 ? d.hour - 12 : d.hour);
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final min = d.minute.toString().padLeft(2, '0');
    return '$month ${d.day}, $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: _buildBody(),
      bottomNavigationBar: FloatingNavbar(
        currentIndex: currentIndex,
        onTap: (index) async {
          if (index == 1) {
            setState(() => currentIndex = 1);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddProblemScreen()),
            );
            setState(() => currentIndex = 0);
            _loadProblems(); // Refresh the feed after posting
          } else {
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
    if (currentIndex == 2) {
      return const AccountScreen();
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            HomeHeader(
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Positioned(
              bottom: -10,
              left: 0,
              right: 0,
              child: CategorySection(
                categories: _chipCategories,
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
        const SizedBox(height: 30),
        Expanded(
          child: _loadingProblems
              ? const Center(child: CircularProgressIndicator())
              : _visibleProblems.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.trim().isNotEmpty
                            ? 'No results for "${_searchQuery.trim()}"'
                            : "No problems yet. Tap + to post one!",
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 10, bottom: 130),
                      children: _visibleProblems.map((doc) {
                        final d = doc;
                        final steps = (d['steps'] as List?)
                                ?.map((s) => s as String)
                                .toList() ??
                            <String>[];
                        final authorName = (d['authorName'] as String?) ?? '';
                        final authorUsername =
                            (d['authorUsername'] as String?) ?? '';
                        return ProblemCard(
                          title: (d['title'] ?? '').toString(),
                          description: (d['description'] ?? '').toString(),
                          category: (d['category'] ?? 'Other').toString(),
                          userName: authorName.isNotEmpty
                              ? authorName
                              : authorUsername,
                          timeStamp: _formatTime(
                              d['createdAt'] as Timestamp?),
                          steps: steps,
                        );
                      }).toList(),
                    ),
        ),
      ],
    );
  }
}

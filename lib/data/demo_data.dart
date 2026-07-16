import 'package:cloud_firestore/cloud_firestore.dart';

/// Static, offline demo data used when [demoModeEnabled] is on.
///
/// This mirrors the real Firestore collections (`categories`, `problems`,
/// `users`) so the UI looks and behaves identically with or without a backend.

/// The demo user's username. Matches the seeded profile in [demoUserSeed].
const String demoUsername = 'demo_user';

/// Categories shown in chips and the "Post a Problem" picker. Order matters
/// (mirrors the Firestore seed in [DataService]).
const List<Map<String, dynamic>> demoCategories = [
  {'name': 'Electronics', 'slug': 'electronics', 'order': 1},
  {'name': 'Computer', 'slug': 'computer', 'order': 2},
  {'name': 'Mobile', 'slug': 'mobile', 'order': 3},
  {'name': 'Home Repair', 'slug': 'home_repair', 'order': 4},
  {'name': 'Other', 'slug': 'other', 'order': 5},
  {'name': 'Laptop', 'slug': 'laptop', 'order': 6},
  {'name': 'Networking', 'slug': 'networking', 'order': 7},
  {'name': 'Printer', 'slug': 'printer', 'order': 8},
  {'name': 'Software', 'slug': 'software', 'order': 9},
  {'name': 'Gaming Console', 'slug': 'gaming_console', 'order': 10},
];

/// Seed profile for [demoUsername].
const Map<String, dynamic> demoUserSeed = {
  'username': demoUsername,
  'fullName': 'Demo User',
  'createdAt': null,
  'profileImage': null,
};

/// Builds a fresh list of seed problems. `createdAt` uses real [Timestamp]s so
/// the home feed's time formatting is exercised.
List<Map<String, dynamic>> _buildSeedProblems() => [
      {
        'title': 'WiFi keeps disconnecting on laptop',
        'description':
            'My laptop drops the WiFi connection every few minutes, especially during video calls.',
        'category': 'Networking',
        'steps': [
          'Forget the network and reconnect',
          'Update the network driver',
          'Switch to the 5GHz band',
        ],
        'authorName': 'Alice Smith',
        'authorUsername': 'alice',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 14, 9, 30)),
      },
      {
        'title': 'Laptop screen is flickering',
        'description':
            'The display flickers whenever I move the lid. External monitor works fine.',
        'category': 'Laptop',
        'steps': [
          'Update the graphics driver',
          'Check the display cable',
        ],
        'authorName': 'Bob Jones',
        'authorUsername': 'bob',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 13, 18, 5)),
      },
      {
        'title': 'Printer prints blank pages',
        'description':
            'The printer feeds paper but nothing is printed. Ink levels look full.',
        'category': 'Printer',
        'steps': [
          'Run the printhead cleaning cycle',
          'Replace the ink cartridges',
        ],
        'authorName': 'Carol White',
        'authorUsername': 'carol',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 12, 11, 0)),
      },
      {
        'title': 'Phone will not charge past 80%',
        'description':
            'My phone stops charging at 80% and gets warm. Tried different cables.',
        'category': 'Mobile',
        'steps': [
          'Disable optimized charging',
          'Clean the charging port',
        ],
        'authorName': 'David Lee',
        'authorUsername': 'david',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 11, 20, 45)),
      },
      {
        'title': 'App crashes on startup',
        'description':
            'The FixIt app closes immediately after the splash screen on my device.',
        'category': 'Software',
        'steps': [
          'Clear the app cache',
          'Reinstall the app',
          'Update to the latest version',
        ],
        'authorName': 'Eve Adams',
        'authorUsername': 'eve',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 10, 8, 15)),
      },
      {
        'title': 'PC is very slow to boot',
        'description':
            'Startup takes over 3 minutes and the disk light stays busy the whole time.',
        'category': 'Computer',
        'steps': [
          'Disable unnecessary startup programs',
          'Run a disk defragmentation',
          'Check for malware',
        ],
        'authorName': 'Frank Miller',
        'authorUsername': 'frank',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 9, 22, 0)),
      },
    ];

/// Mutable in-memory stores. These are reset by [resetDemoStore] between
/// tests (and on app start) so that posting/updating/deleting during a session
/// is reflected live (e.g. a posted problem shows in the feed after returning
/// home), while each test starts from a known state.
List<Map<String, dynamic>> demoProblemsStore = _buildSeedProblems();
Map<String, dynamic> demoUserStore = Map<String, dynamic>.from(demoUserSeed);

/// Restores the demo stores to their seeded state. Call this in test `setUp`.
void resetDemoStore() {
  demoProblemsStore = _buildSeedProblems();
  demoUserStore = Map<String, dynamic>.from(demoUserSeed);
}

/// Names of all categories (used by tests/validation).
List<String> get demoCategoryNames =>
    demoCategories.map((c) => c['name'] as String).toList();
